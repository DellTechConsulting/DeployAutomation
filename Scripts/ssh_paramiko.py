import paramiko
import sys
import time
ip = sys.argv[1]
curr_pass = sys.argv[2]
password = sys.argv[3]

ssh_conn = paramiko.SSHClient()
ssh_conn.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh_conn.load_system_host_keys()
ssh_conn.connect(ip, username='admin', password=curr_pass)

def chage_password_change(ssh_conn, password, curr_pass):
   '''
   If got error on login then set with interactive mode.
   '''
   print("starting password change")
   interact = ssh_conn.invoke_shell()

   time.sleep(5)
   resp = interact.recv(20000)
   print(resp)
   if "UNIX password" in str(resp):
        interact.send(curr_pass + '\n')
        print("successfully added UNIX password, now looking for New password")
   else:
      message = "could not find 'UNIX password' in shell: {}".format(str(resp))
      print(message)
      exit()
    
   time.sleep(5)
   resp = interact.recv(20000)
   print(resp)
   if "New password" in str(resp):
        interact.send(password + '\n')
        print("successfully added New password, now looking for Retype new password")
   else:
      message = "could not find 'New password' in shell: {}".format(str(resp))
      print(message)
      exit()

   time.sleep(5)
   resp = interact.recv(20000)
   print(resp)
   if "Retype new password" in str(resp):
        interact.send(password + '\n')
        print("successfully added Retype new password, password change success")
   else:
      message = "could not find 'Retype new password' in shell: {}".format(str(resp))
      print(message)
      exit()

   interact.shutdown(2)
   if interact.exit_status_ready():
       print("EXIT :", interact.recv_exit_status())

   print("Last Password")
   print("LST :", interact.recv(-1))
chage_password_change(ssh_conn, password, curr_pass)
ssh_conn.close()