app_user=roboshop
script=$(realpath "$0")
script_path=$(dirname "$script")
log_file=/tmp/Roboshop1.log

func_print_head() {
  echo -e "\e[35m>>>> $1 <<<<\e[0m"
 }

func_stat_check() {

  if [ $1 -eq 0 ]; then
     echo -e "\e[32mSUCCESS\e[0m"
  else
     echo -e "\e[32MFAILURE\e[0m"
     echo "refer the log information"
     exit 1
  fi
}
func_app_prereq() {
  func_print_head "add user"
  id ${app_user} &>>/tmp/Roboshop1.log
  if [ $? -ne 0 ]; then
    useradd ${app_user} &>>/tmp/Roboshop1.log
  fi
  func_stat_check $?

  func_print_head "create dir"
  rm -rf /app &>>$log_file
  mkdir /app &>>$log_file
  func_stat_check $?
  func_print_head "Download app content"
  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>$log_file
  cd /app
  func_stat_check $?

  func_print_head "unzip content"
  unzip /tmp/${component}.zip &>>$log_file
  cd /app
  func_stat_check $?
 }
 func_schema_setup() {
      if [ "$schema_setup" == "mongo" ]; then
     func_print_head "Copying mongo repo"
     cp ${script_path}/mongo.repo /etc/yum.repos.d/mongo.repo &>>$log_file
     func_stat_check $?

     func_print_head "installing mongodb"
     yum install mongodb-org-shell -y &>>$log_file
     func_stat_check $?

     func_print_head "load schema"
      mongo --host mongodb-dev.pavan345.online </app/schema/${component}.js &>>$log_file
      func_stat_check $?
     fi

     if [ "${schema_setup}" == "mysql" ]; then
         func_print_head "install mysql"
         yum install mysql -y &>>$log_file
         func_stat_check $?

           func_print_head "load schema"
           mysql -h mysql-dev.pavan345.online -uroot -p${mysql_root_password} < /app/schema/shipping.sql &>>$log_file
            func_stat_check $?
     fi
 }
func_systemd_setup() {

      func_print_head "copying services"
      cp ${script_path}/${component}.service /etc/systemd/system/${component}.service &>>$log_file
      func_stat_check $?
      func_print_head "system services"
      systemctl daemon-reload &>>$log_file
      systemctl enable ${component} &>>$log_file
      systemctl start ${component} &>>$log_file
      func_stat_check $?
}
func_nodejs() {

    func_print_head "conf Nodejs repos"
    curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$log_file
    func_stat_check $?

    func_print_head "install nodejs"
    yum install nodejs -y &>>$log_file
    func_stat_check $?

    func_app_prereq

    func_print_head "instal dependencies"
    npm install &>>$log_file
    func_stat_check $?

    func_schema_setup

    func_systemd_setup


}

func_java() {
       func_print_head "install maven"
       yum install maven -y &>>$log_file
       func_stat_check $?

       func_app_prereq

      func_print_head "download maven dependencies"
       mvn clean package &>>$log_file
       mv target/${component}-1.0.jar ${component}.jar &>>$log_file
      func_stat_check $?

      func_systemd_setup

      func_schema_setup

}

func_python() {
func_print_head "install python36"
yum install python36 gcc python3-devel -y
func_stat_check $?

func_app_prereq

func_print_head "pip3.6 install"
pip3.6 install -r requirements.txt
func_stat_check $?

func_print_head "Copying payment service"
sed -i -e "s|rabbitmq_appuser_password|${rabbitmq_appuser_password}|" ${script_path}/payment.service
func_stat_check $?
func_systemd_setup
}

