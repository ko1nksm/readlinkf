FROM debian
ENV DEBCONF_NOWARNINGS yes
RUN apt-get update && apt-get install -y tree
COPY ./ /
