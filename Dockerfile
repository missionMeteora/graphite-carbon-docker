FROM      ubuntu:14.04
MAINTAINER Maxim Kupriianov <max@meteora.co>

# Install required packages
run	apt-get -y update && apt-get -y install python-ldap python-cairo python-django python-twisted python-django-tagging python-simplejson python-memcache python-pysqlite2 python-support python-pip gunicorn supervisor nginx-light
run	pip install whisper
run	pip install --install-option="--prefix=/var/lib/graphite" --install-option="--install-lib=/var/lib/graphite/lib" carbon
run	pip install --install-option="--prefix=/var/lib/graphite" --install-option="--install-lib=/var/lib/graphite/webapp" graphite-web

# Add system service config
add	./nginx.conf /etc/nginx/nginx.conf
add	./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add graphite config
add	./initial_data.json /var/lib/graphite/webapp/graphite/initial_data.json

# Local settings
ADD	./local_settings.py /var/lib/graphite/webapp/graphite/local_settings.py
RUN sed -i "s#^\(SECRET_KEY = \).*#\1\"`python -c 'import os; import base64; print(base64.b64encode(os.urandom(40)))'`\"#" /var/lib/graphite/webapp/graphite/local_settings.py

add	./carbon.conf /var/lib/graphite/conf/carbon.conf
add	./storage-schemas.conf /var/lib/graphite/conf/storage-schemas.conf
run	mkdir -p /var/lib/graphite/storage/whisper
run	touch /var/lib/graphite/storage/graphite.db /var/lib/graphite/storage/index
run	chown -R www-data /var/lib/graphite/storage
run	chmod 0775 /var/lib/graphite/storage /var/lib/graphite/storage/whisper
run	chmod 0664 /var/lib/graphite/storage/graphite.db
run	cd /var/lib/graphite/webapp/graphite && python manage.py syncdb --noinput

EXPOSE 8080 2003/udp 2004 7002
CMD exec supervisord -n
