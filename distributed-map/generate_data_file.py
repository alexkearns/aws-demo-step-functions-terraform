import json

list_of_objs = []
with open("data_source.json", "w") as f:
    for i in range(1000):
      list_of_objs.append({"inputNumber": i})

    f.write(json.dumps(list_of_objs))