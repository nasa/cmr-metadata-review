import os
import os.path
import requests
import xmltodict
import sys
import json

from pyQuARC import ARC

# The field path has the doctype (e.g. Collection/) as a prefix, this should be removed.
def remove_doctype(field_path):
    pos = field_path.find("/")
    path = field_path
    if (pos != -1):
        path = field_path[pos+1:]
    return path

# Given the specified path and the check being applied, incude the check result of the value/message to the "result" dictionary.
# If the check is valid (no errors), just include "OK; "
def assign_results(path, check, check_data, result):
    if "valid" in check_data:                    
        valid = check_data["valid"]        
        # if check is valid, use "OK"
        if valid:
            if result[path] == "":
                result[path] += "OK; "
        else:
            # prior check said this was OK, but this check says not.
            if result[path] == "OK; ":
                result[path] = ""

            # Use the message if we have one.
            if check_data["message"]:
                for message in check_data["message"]:
                    result[path] += message + "; "
            # Otherwise just mention the check failed.
            else:     
                result[path] += check+" failed;"

# This just cleans up the result path, it will remove a trailing ; and if the result path's value == "" then will remove it altogher from the
# dictionary, hence all checks passed.
def trim_result_path(result, path):
    if result[path].endswith("; "):
        result[path] = result[path][:len(result[path])-2]

    if result[path] == "":
        del result[path]

# Main logic that parses through the errors for the specified field path and assigns the results of the checks to the "result" dictionary.
# The "result" dictionary is ["path":"result1;result2;"]
def parse_checks(field_path, errors, result):
    path = remove_doctype(field_path)
    result[path] = ""
    checks = errors[field_path].keys()
    
    for check in checks:
        check_data = errors[field_path][check]
        assign_results(path, check, check_data, result)

    trim_result_path(result, path)

# Main that calls the ARC library, with the specified metadata file (arg1) and theh specified format (arg2), parses the results and transforms the results
# into something cmr dashboard can use.
if __name__ == "__main__":
    if (len(sys.argv) != 3):
        print("Usage python3 dashboard_checker.py [file] [format]")
        exit()
    file = sys.argv[1]
    format = sys.argv[2]
    result = {}
    arc = ARC(file_path=file, metadata_format=format or ECHO10)
    validation_results = arc.validate()
    arc_errors = arc.errors
    for error in arc_errors:
        errors = error["errors"]
        for field_path in errors.keys():
            parse_checks(field_path, errors, result)
    print(json.dumps(result))

