script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

func_print_head "install remirepo"
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$log_file
func_stat_check $?

func_print_head "enable redis"
dnf module enable redis:remi-6.2 -y &>>$log_file
func_stat_check $?

func_print_head "install redis"
yum install redis -y &>>$log_file
func_stat_check $?

func_print_head "change host"
sed -i -e 's|127.0.0.1|0.0.0.0|' /etc/redis.conf /etc/redis/redis.conf &>>$log_file
func_stat_check $?

func_print_head "start redis service"
systemctl enable redis &>>$log_file
systemctl start redis &>>$log_file
systemctl restart redis &>>$log_file
func_stat_check $?