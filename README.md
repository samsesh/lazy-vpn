# lazy-vpn
- lazy-vpn is a script that tries to make your work easier and gathers the most used vpn in one place so that you can easily set up a vpn server on your ubuntu server.
Apart from that, it has the ability to improve the server and show the capabilities of the server
- run 
```bash
bash <(curl -sSL https://github.com/samsesh/lazy-vpn/raw/Localhost/lazy.sh)
```
- run with tmux
```bash
tmux new -s lazy "bash <(curl -sSL https://github.com/samsesh/lazy-vpn/raw/Localhost/lazy.sh)"
```
> It is better to use tmux so that if the ssh connection with the server is interrupted, the command will not be broken, If the connection is interrupted, you can return to the installation page with the following command after connecting to the server
```bash
tmux a -d -t lazy
```
## ToDo
- [ ] add uninstaller
- [ ] Checking the existence of a VPN server that does not interfere with the installation of other services
## link 
- [hiddify](https://github.com/hiddify/hiddify-config/)
- [ShadowSocks ssr](https://github.com/ShadowsocksR-Live/shadowsocksr-native)
- [x-ui (alireza0)](https://github.com/alireza0/x-ui)
- [3x-ui (Sanaei)](https://github.com/MHSanaei/3x-ui)
- [x-ui (chinese)](https://github.com/vaxilu/x-ui/)
- [x-ui (Kafka)(en)](https://github.com/FranzKafkaYu/x-ui)
- [xray-reality](https://github.com/sajjaddg/xray-reality)
- [marzban (🐳 docker base)](https://github.com/Gozargah/Marzban)
- [Hi Hysteria](https://github.com/emptysuns/Hi_Hysteria)
- [NaiveProxy](https://github.com/yonggekkk/NaiveProxy-yg)
- [wireguard (🐳 docker base)](https://github.com/samsesh/wireguard-docker)
- [wireguard](https://github.com/angristan/wireguard-install)
- [openconnect server (🐳 docker base)](https://github.com/samsesh/ocserv-docker)
- [openconnect server](https://github.com/sfc9982/AnyConnect-Server/)
- [openvpn server (🐳 docker base)](https://github.com/samsesh/openvpn-dockercompose)
- [openvpn server (pritunl)](https://github.com/samsesh/pritunl-install)
- [openvpn server](https://github.com/angristan/openvpn-install)
- [softether server](https://github.com/samsesh/softether-install)
- [proxy server (🐳 docker base)](https://github.com/samsesh/3proxy-docker-compose)
---
- [Ubuntu-Optimizer 🐧](https://github.com/samsesh/Ubuntu-Optimizer)
- [cfwarp repository link](https://gitlab.com/rwkgyg/CFwarp/)