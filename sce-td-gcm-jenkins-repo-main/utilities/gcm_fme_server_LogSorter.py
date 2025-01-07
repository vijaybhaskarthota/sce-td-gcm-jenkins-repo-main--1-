# This script reads a directory and subdirectories finding all *.log files.  It then opens all log files and reads them.  
# Next it will print out all log entries sorted by date and time, and appening the name of the oriingal log file it came from.
# Finally it will create an additional file with only the ERRORS returned.
import os
import re
from datetime import datetime,timedelta
import argparse
import timeit


# Function to extract a valid date from a log entry
def extract_date(entry):
    date_match = re.search(r'\w{3}-\d{2}-\w{3}-\d{4} \d{2}:\d{2}:\d{2}\.\d{3} [APM]{2}', entry)
    if date_match:
        date_str = date_match.group()
        date_format = "%a-%d-%b-%Y %I:%M:%S.%f %p"
        date_obj = datetime.strptime(date_str, date_format)
        return date_obj
    return None

# Function to find the nearest valid date for a line without a date
def find_nearest_date(lines, index):
    # Find the nearest valid date before and after the line
    before_date = None
    after_date = None

    for i in range(index - 1, -1, -1):
        date = extract_date(lines[i])
        if date:
            before_date = date
            break

    for i in range(index + 1, len(lines)):
        date = extract_date(lines[i])
        if date:
            after_date = date
            break

    # Use the nearest date, or None if both before and after are None
    return before_date if before_date else after_date

def filter_error_lines(input_file_path, output_file_path):
    """An output file of only ERROR lines will be created"""
    try:
        with open(input_file_path, 'r') as input_file, open(output_file_path, 'w') as output_file:
            for line in input_file:
                if "ERROR" in line:
                    output_file.write(line)
        print(f"Filtered 'ERROR' lines saved to {output_file_path}\n")
    except FileNotFoundError:
        print(f"Error: The input file '{input_file_path}' does not exist.")

t_start = timeit.default_timer()

start_time = datetime.now()
start_time = start_time.strftime("%H:%M:%S on %d-%m-%Y")
print(f"\nStarting Processing at {start_time}")

# Start Add: Oct 13, 2023 to provide parameters to be passed when calling the python script.
# Initialize the argument parser
parser = argparse.ArgumentParser(description="Sort log entries by date and time. Recommend removing tomcat and job logs from the search directory. ")

# Add arguments for specifying the log directory and output file path
parser.add_argument(
    "--log-directory",
    required=True,
    help="Directory containing the log files (recursively).",
)

#parser.add_argument(
#    "--output-file",
#    required=False,
#    help="Path to the output file where sorted log entries will be saved",
#)

# Parse the command-line arguments
args = parser.parse_args()

# End Add: Oct 13, 2023

# Directory containing log files (recursively)
# log_directory = "C:\\FMESystemShare21\\resources\\logs\\core"
# log_directory = "\\sce\\workgroup\\Appdata\\resources\\logs"
# log_directory = "/Users/steve.maccabe/Desktop/Cases/C690000/C692885 - Yash - Engine Drops/Oct Incident/logs/logs"
log_directory = args.log_directory


# Open the output file in write mode
# output_file_path = "C:\\temp\\stevepython\\output\\AllLogsSorted.txt"
#output_file_path = "/Users/steve.maccabe/Desktop/Cases/C690000/C692885 - Yash - Engine Drops/Oct Incident/logs/AllLogsSorted.txt"
log_directory = args.log_directory
# output_file_path = args.output_file dropped on Nov 10, 2023 to use intial log directory
#output_file_path = log_directory + '/AllLogsMerged.txt'
output_file_path = './AllLogsMerged.txt'
#print(f"Fileout: {output_file_path}")
output_file = open(output_file_path, 'w')
output_file.write(f"All Log File Entries Sorted by Date and Time\n")

# Read and process all log entries from all log files
all_log_entries = []
# Initialize counters
log_file_count = 0
starting_fme_server_count = 0
stopping_fme_server_count = 0
starting_fatal_count = 0
starting_error_count = 0
starting_warn_count = 0
exclude = set(['tomcat','jobs'])
for root, dirs, files in os.walk(log_directory):
    dirs[:] = [d for d in dirs if d not in exclude]
    for file_name in files:
        #if file_name.endswith('.log')
        #print(f"Timestamp:{datetime.fromtimestamp(os.path.getmtime(os.path.join(root, file_name)))}\t{(datetime.fromtimestamp(os.path.getmtime(os.path.join(root, file_name))) > (datetime.now()- timedelta(days=2)))}\tfile:{file_name}")
        if file_name.endswith('.log') and (datetime.fromtimestamp(os.path.getmtime(os.path.join(root, file_name))) > (datetime.now()- timedelta(days=2))): 
            print(f"Timestamp:{datetime.fromtimestamp(os.path.getmtime(os.path.join(root, file_name)))}\tfile:{file_name}")
            log_file_path = os.path.join(root, file_name)
            with open(log_file_path, 'r') as log_file:
                log_file_count += 1  # Increment the log file count
                log_entries = log_file.readlines()
                for index, entry in enumerate(log_entries):
                    date = extract_date(entry)
                    if date:
                        formatted_entry = f"{entry.strip()} : {file_name}"
                        if "fme server up and running" in entry.lower() and "_fmeserver" in file_name.lower():
                            starting_fme_server_count += 1
                            print(f"FME Server Started at: {date}")
                        if "fme server shutting down" in entry.lower() and "_fmeserver" in file_name.lower():
                            stopping_fme_server_count += 1
                            print(f"FME Server Stopping at: {date}")
                        if " error " in entry.lower():
                            starting_error_count += 1
                        if " warn " in entry.lower():
                            starting_warn_count += 1
                        all_log_entries.append((date, formatted_entry, file_name))
                    else:
                        nearest_date = find_nearest_date(log_entries, index)
                        if nearest_date:
                            formatted_entry = f"{entry.strip()} : {file_name}"
                            if "fme server up and running" in entry.lower() and "_fmeserver" in file_name.lower():
                                starting_fme_server_count += 1
                                print(f"FME Server Started at: {nearest_date}")
                            if "fme server stopping" in entry.lower() and "_fmeserver" in file_name.lower():
                                stopping_fme_server_count += 1
                                print(f"FME Server Stopping at: {nearest_date}")
                            if " fatal " in entry.lower():
                                starting_fatal_count += 1
                            if " error " in entry.lower():
                                starting_error_count += 1
                            if " warn " in entry.lower():
                                starting_warn_count += 1
                            all_log_entries.append((nearest_date, formatted_entry, file_name))

# Sort all log entries by date and time, treating None as a minimum date
sorted_entries = sorted(all_log_entries, key=lambda entry: (entry[0] or datetime.min))

# Write sorted entries to the output file with a newline character at the end of each line
for entry in sorted_entries:
    output_file.write(f"{entry[1]}\n")

output_file.close()

print(f"\nNumber of log files scanned: {log_file_count}")
print(f"Number of occurrences of 'FME Server up and running': {starting_fme_server_count}")
print(f"Number of occurrences of 'FME Server stopping': {stopping_fme_server_count}")
print(f"Number of occurrences of ' FATAL ': {starting_fatal_count}")
print(f"Number of occurrences of ' ERROR ': {starting_error_count}")
print(f"Number of occurrences of ' WARN ': {starting_warn_count}")
print(f"\nMerged Log File Saved to {output_file_path}\n")


# Report only Error Entries to separate file
#filter_error_lines(input_file_path, output_file_path)
input_sorted_log=output_file_path
#output_errors_only=log_directory + "/ErrorsOnly.txt"
output_errors_only="./ErrorsOnly.txt"

filter_error_lines(input_sorted_log, output_errors_only)

done_time = datetime.now()
done_time = done_time.strftime("%H:%M:%S on %d-%m-%Y")
print(f"Completed Processing at {done_time}")

# record end time
t_end = timeit.default_timer()
 
# calculate elapsed time and print
elapsed_time = round((t_end - t_start), 1)
print(f"Elapsed time: {elapsed_time} s\n")