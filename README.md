My project is a food logging app that allows users to store food logs containing the name of the food and the calories, which can later be used to pull data from and gather information. The cloud services I used were Compute Engine (VM), cloud storage (Bucket), Cloud run, and Firebase authentication. The services all interact with eachother, firebase allows authenticated users to upload food logs to the flask server on the VM, then the VM sends those logs into my bucket in cloud storage and finally my cloud run function allows you to see how many logs are stored in the bucket. 

How to run: To run my project you need to use a curl command to upload a log to the flask server and after that you will see the new log show up in the bucket. 

curl -X POST http://35.222.57.90:5000/log \
-H "Content-Type: application/json" \
-d '{"food":"[food]","calories":[amount]}'

