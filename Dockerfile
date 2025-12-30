FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive
ENV PRINTER_IP=printer.home.arpa
ENV PRINTER_NAME=Canon-Network-Printer

RUN apt-get update && apt-get install -y \
    cups \
    cups-client \
    cups-bsd \
    wget \
    ca-certificates \
    ghostscript \
    libgl1 \
    libusb-1.0-0 \
    libxml2 \
    tar \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN wget https://gdlp01.c-wss.com/gds/8/0100007658/47/linux-UFRII-drv-v620-m17n-20.tar.gz \
    && tar xzvf linux-UFRII-drv-v620-m17n-20.tar.gz

WORKDIR /tmp/linux-UFRII-drv-v620-m17n
RUN dpkg -i x64/Debian/*.deb || apt-get update && apt-get install -f -y 

WORKDIR /tmp
RUN rm -r linux-UFRII-drv-v620-m17n
RUN rm linux-UFRII-drv-v620-m17n-20.tar.gz

RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
    sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
    echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
    echo "DefaultEncryption IfRequested" >> /etc/cups/cupsd.conf


EXPOSE 631

CMD dbus-daemon --system --fork && avahi-daemon --no-drop-root & /usr/sbin/cupsd -f
