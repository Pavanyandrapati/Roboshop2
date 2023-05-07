script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

func_print_head "installing nginx"
yum install nginx -y &>>$log_file
func_stat_check $?

func_print_head "start nginx services"
systemctl enable nginx  &>>$log_file
systemctl start nginx &>>$log_file
func_stat_check $?

func_print_head "removing contents"
rm -rf /usr/share/nginx/html/* &>>$log_file
func_stat_check $?

func_print_head "Downloading content"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>$log_file
cd /usr/share/nginx/html
func_stat_check $?

func_print_head "unzip content"
unzip /tmp/frontend.zip &>>$log_file
func_stat_check $?

func_print_head "Copying roboshop serives"
cp ${script_path}/roboshop.service /etc/nginx/default.d/roboshop.conf &>>$log_file
func_stat_check $?
systemctl restart nginx &>>$log_file