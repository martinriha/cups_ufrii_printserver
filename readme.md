docker build -t cups-ufrii .
docker run -d --name cups -p 631:631 --ulimit nofile=65535:65535 --restart unless-stopped cups-ufrii
lpadmin -p CanonMF643 -E -v ipp://printer.home.arpa/ipp/print -P /usr/share/cups/model/CNRCUPSMF645CZK.ppd
