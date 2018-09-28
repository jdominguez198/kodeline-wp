#!/bin/bash
set -euo pipefail

mkdir -p /var/www/html
cd /var/www/html
user='www-data'
group='www-data'

file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

# Set wp-config variables
uniqueEnvs=(
    AUTH_KEY
    SECURE_AUTH_KEY
    LOGGED_IN_KEY
    NONCE_KEY
    AUTH_SALT
    SECURE_AUTH_SALT
    LOGGED_IN_SALT
    NONCE_SALT
)
envs=(
    WORDPRESS_DB_HOST
    WORDPRESS_DB_USER
    WORDPRESS_DB_PASSWORD
    WORDPRESS_DB_NAME
    WORDPRESS_DB_CHARSET
    WORDPRESS_DB_COLLATE
    "${uniqueEnvs[@]/#/WORDPRESS_}"
    WORDPRESS_TABLE_PREFIX
    WORDPRESS_DEBUG
    WORDPRESS_CONFIG_EXTRA
)
haveConfig=
for e in "${envs[@]}"; do
    file_env "$e"
    if [ -z "$haveConfig" ] && [ -n "${!e}" ]; then
        haveConfig=1
    fi
done

if [ "$haveConfig" ]; then
    : "${WORDPRESS_DB_HOST:=mysql}"
    : "${WORDPRESS_DB_USER:=root}"
    : "${WORDPRESS_DB_PASSWORD:=}"
    : "${WORDPRESS_DB_NAME:=wordpress}"
    : "${WORDPRESS_DB_CHARSET:=utf8}"
    : "${WORDPRESS_DB_COLLATE:=}"

    sed -ri -e 's/\r$//' wp-config*

    if [ ! -e wp-config.php ]; then
        cp wp-config-sample.php wp-config.php
        chown "$user:$group" wp-config.php
    fi

    # see http://stackoverflow.com/a/2705678/433558
    sed_escape_lhs() {
        echo "$@" | sed -e 's/[]\/$*.^|[]/\\&/g'
    }
    sed_escape_rhs() {
        echo "$@" | sed -e 's/[\/&]/\\&/g'
    }
    php_escape() {
        local escaped="$(php -r 'var_export(('"$2"') $argv[1]);' -- "$1")"
        if [ "$2" = 'string' ] && [ "${escaped:0:1}" = "'" ]; then
            escaped="${escaped//$'\n'/"' + \"\\n\" + '"}"
        fi
        echo "$escaped"
    }
    set_config() {
        key="$1"
        value="$2"
        var_type="${3:-string}"
        start="(['\"])$(sed_escape_lhs "$key")\2\s*,"
        end="\);"
        if [ "${key:0:1}" = '$' ]; then
            start="^(\s*)$(sed_escape_lhs "$key")\s*="
            end=";"
        fi
        sed -ri -e "s/($start\s*).*($end)$/\1$(sed_escape_rhs "$(php_escape "$value" "$var_type")")\3/" wp-config.php
    }

    set_config 'DB_HOST' "$WORDPRESS_DB_HOST"
    set_config 'DB_USER' "$WORDPRESS_DB_USER"
    set_config 'DB_PASSWORD' "$WORDPRESS_DB_PASSWORD"
    set_config 'DB_NAME' "$WORDPRESS_DB_NAME"
    set_config 'DB_CHARSET' "$WORDPRESS_DB_CHARSET"
    set_config 'DB_COLLATE' "$WORDPRESS_DB_COLLATE"

    for unique in "${uniqueEnvs[@]}"; do
        uniqVar="WORDPRESS_$unique"
        if [ -n "${!uniqVar}" ]; then
            set_config "$unique" "${!uniqVar}"
        else
            # if not specified, let's generate a random value
            currentVal="$(sed -rn -e "s/define\((([\'\"])$unique\2\s*,\s*)(['\"])(.*)\3\);/\4/p" wp-config.php)"
            if [ "$currentVal" = 'put your unique phrase here' ]; then
                set_config "$unique" "$(head -c1m /dev/urandom | sha1sum | cut -d' ' -f1)"
            fi
        fi
    done

    if [ "$WORDPRESS_TABLE_PREFIX" ]; then
        set_config '$table_prefix' "$WORDPRESS_TABLE_PREFIX"
    fi

    if [ "$WORDPRESS_DEBUG" ]; then
        set_config 'WP_DEBUG' 1 boolean
    fi

fi

# Create htaccess file if does not exists
if [ ! -e .htaccess ]; then
    cp /var/www-conf/.htaccess /var/www/html/.htaccess
    chown "$user:$group" .htaccess
fi