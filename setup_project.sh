  #!/bin/bash

abort() {
echo " Ctrl+C caught   "
echo " Starting cleanup process  ... "
        if [ -d $cows ];then
        tar cf "${cows}_archive" "$cows"
        rm -rf "$cows"
        echo "Partial data saved and removed"
        fi
       
}
trap abort  SIGINT




echo "Starting deployment.."
echo "Verifying whether python3 exists on the system...."



if python3 --version;then
        echo "Great! Python3 is there, moving on"
else
        echo "Hmm, Python3 not found "
fi  
sleep 0.5

echo "Setting up your workspace now "
read -p "Give your folder a unique name: " folder  
cows="attendance_tracker_$folder"
if [ -d $cows ];then
        echo "That name is already taken"
else
        mkdir -p "$cows"
        mkdir "$cows/Helpers"
        mkdir "$cows/reports"
   
sleep 1

# creating attendance_checker.py file
cat > "$cows/attendance_checker.py" << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

#CONFIG.json file
cat > "$cows/Helpers/config.json" << 'EOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF

#assets.csv file
cat > "$cows/Helpers/assets.csv" << 'EOF'
Names,Email,Attendance Count
Alice Johnson,alice@example.com,14
Bob Smith,bob@example.com,7
Charlie Davis,charlie@example.com,4
Diana Ross,diana@example.com,12
Edward King,edward@example.com,10
EOF

#reports.log file
cat > "$cows/reports/reports.log" << 'EOF'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your
attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie
Davis, your attendance is 26.7%. You will fail this class
EOF
fi

read -p "Do you want to update the attendance thresholds? (y/n): " choice
if [ "$choice" = "y" ]; then
        read -p "Enter Warning threshold in %:  " warning
        read -p "Enter Failure threshold %: " failure
        sed -i "s/75/$warning/" "$cows/Helpers/config.json"
        sed -i "s/50/$failure/" "$cows/Helpers/config.json"
        echo "Threshold modified"
fi

echo " delypoment  $cows  successfully "

