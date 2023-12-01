from itertools import combinations
import sys

L = sys.argv[1:]

for i in combinations(L,2):
    print(f"cilium clustermesh connect --context {i[0]} --destination-context {i[1]}")
