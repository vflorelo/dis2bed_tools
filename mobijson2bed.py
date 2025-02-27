#!/usr/bin/python3
import json
import sys
def mean(num_list):
    return sum(num_list)/len(num_list)
data_file = sys.argv[1]
with open(data_file) as json_file:
    data  = json.load(json_file)
sequence  = data["sequence"]
regions   = data["prediction-disorder-mobidb_lite"]["regions"]
scores    = data["prediction-disorder-mobidb_lite"]["scores"]
accession = data["acc"]
for region in regions:
    start_pos  = region[0] - 1
    end_pos    = region[1]
    sub_seq    = sequence[start_pos:end_pos]
    mean_score = mean(scores[start_pos:end_pos])
    print(accession + "\t" + str(start_pos) + "\t" + str(end_pos) + "\t" + sub_seq + "\t" + str(mean_score) + "\t" + "+")