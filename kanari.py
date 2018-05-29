import sys
import glob
from datetime import datetime
from dateutil.parser import parse
import time


def file_get_contents(filename):
    with open(filename) as f:
        return f.read()

if len(sys.argv) != 4:
    print(
        "\r\n\r\nUsage: python kanari.py [path] [number of kanari files] [max age in days]\r\nExample:  python kanari.py \"/srv/storage/backups/libvirt-filesystems/*/backup_kanarie.txt\" 13 8\r\n\r\n")
    sys.exit()

path = sys.argv[1]
numberOfKanari = sys.argv[2]
maxAgeKanari = sys.argv[3]

items = glob.glob(path)

# verify number of kanaries
itemsFoundCnt = len(items)
if int(itemsFoundCnt) != int(numberOfKanari):
    print("CRITICAL: Number of kanari did not match, expected: {} got: {}".format(numberOfKanari, itemsFoundCnt))
    sys.exit()

now = datetime.now()
totalAge = 0

# verify kanari age
for x in items:
    datestring = file_get_contents(x)

    datestring = datetime.strptime(datestring[0:8], '%Y%m%d')
    # result is a typeof datetime.timedelta
    delta = now - datestring
    sumDelta = 0
    sumDelta = sumDelta + delta.days

    if delta.days > int(maxAgeKanari):
        print("CRITICAL: kanari too old, max days ago expected: {} got date {}".format(maxAgeKanari, delta.days))

average = sumDelta / itemsFoundCnt
print("OK: got {} kanari average age {} days\r\n".format(itemsFoundCnt, sumDelta))
