#!/bin/bash
# ===============================
# Mac 校园网自动登录/注销脚本（支持掉线重连）
# ===============================

USERNAME="2410505449"
PASSWORD="739154"
ISP="@cmcc"

LOGIN_URL="http://172.16.1.38:801/eportal/"
LOGOUT_URL="http://172.16.1.38:801/eportal/?c=ACSetting&a=Logout"

R1="0"
R2="0"
R3="0"
R6="0"
para="00"
MKKEY="123456"

# ---------- 获取本机 IP ----------
get_ip() {
    ipconfig getifaddr en0 || echo "10.1.164.171"
}

# ---------- 检测是否能访问外网 ----------
check_connection() {
    # 尝试 ping 114.114.114.114
    if ping -c 1 -t 1 114.114.114.114 &>/dev/null; then
        return 0  # 网络正常
    else
        return 1  # 需要登录
    fi
}

# ---------- 登录函数 ----------
login() {
    USERIP=$(get_ip)
    echo "$(date): 尝试登录，IP=$USERIP"

    TARGET_URL="${LOGIN_URL}?c=ACSetting&a=Login&loginMethod=1&protocol=http%3A&hostname=172.16.1.38&iTermType=1&wlanuserip=${USERIP}&wlanacip=null&wlanacname=null&redirect=null&session=null&vlanid=0&mac=00-00-00-00-00-00&ip=${USERIP}&enAdvert=0&jsVersion=2.4.3&DDDDD=,0,${USERNAME}${ISP}&upass=${PASSWORD}&R1=${R1}&R2=${R2}&R3=${R3}&R6=${R6}&para=${para}&0MKKey=${MKKEY}&buttonClicked=&redirect_url=&err_flag=&username=&password=&user=&cmd=&Login=&v6ip="

    response=$(curl -s -i -L -c /tmp/campus_cookies.txt -b /tmp/campus_cookies.txt "$TARGET_URL")

    if echo "$response" | grep -q -E "3.htm|认证成功|Login Successful|登录成功"; then
        echo "$(date): 登录成功"
    else
        echo "$(date): 登录失败，请检查账号/IP"
    fi
}

# ---------- 注销函数 ----------
logout() {
    response=$(curl -s -i -L -b /tmp/campus_cookies.txt "$LOGOUT_URL")
    echo "$(date): 注销请求已发送"
}

# ---------- 主程序 ----------
CHECK_INTERVAL=2  # 循环检测间隔，单位：秒，可改为 2、10、120 等

case "$1" in
    login)
        login
        ;;
    logout)
        logout
        ;;
    auto)
        while true; do
            if check_connection; then
                echo "$(date): 网络正常，无需登录"
            else
                login
            fi
            sleep $CHECK_INTERVAL
        done
        ;;
    *)
        echo "用法: $0 {login|logout|auto}"
        ;;
esac
