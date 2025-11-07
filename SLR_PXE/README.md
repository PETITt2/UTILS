# Intergrer PXE a un serveur linux en routeur

---
*note : Je ne sais pas si ce genre de configuration s'effectue de le meme maniere sur un routeur classique (donc ici je parlerai du cas present avec un serveur ubuntu 24.04.3)*

---
## Mise en contexte

mon routeur est actuellement configuré de sorte a ce qu'il ai une sortie sur internet et une sortie sur l'interieur du reseau local, un NAT a ete effectue pour masquer les addresses du reseau interne lors de requettes sur internet.
Le DHCP est utilise pour la distribution d'adresse ip
Et une route par defaut est configuree de sorte a permettre au reseau interne d'acceder a internet

___
|package|utilité|
|---|---|
|dnsmasq|serveur dhcp/DNS local|
|systemd-networkd| gere l'interface reseau via NetPlan|
|iptables + ufw | Pare-feu/NAT|
___

