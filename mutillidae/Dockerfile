FROM edoz90_mutillidae:latest

ADD ./configure_db.sh /tmp/configure_db.sh
RUN /bin/bash /tmp/configure_db.sh
RUN rm /tmp/configure_db.sh

EXPOSE 80 3306
