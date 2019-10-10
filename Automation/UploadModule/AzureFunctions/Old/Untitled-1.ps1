# Invoke-WebRequest -Uri "https://management.azure.com/batch?api-version=2015-11-01" -Method "POST" -Headers 
# @{
#     "Sec-Fetch-Mode"="cors"; 
#     "x-ms-client-session-id"="fe7982e3458d47bf933e7eccde7a8de8"; 
#     "Origin"="https://portal.azure.com"; 
#     "x-ms-command-name"="{ Microsoft_Azure_Storage.Batch:0,CreateStorageAccountHelper.validateStorageAccountNameForCreate:1,StorageHelper.executeStorageNameCheck:1}"; 
#     "Accept-Language"="en"; 
#     "Authorization"="Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6ImFQY3R3X29kdlJPb0VOZzNWb09sSWgydGlFcyIsImtpZCI6ImFQY3R3X29kdlJPb0VOZzNWb09sSWgydGlFcyJ9.eyJhdWQiOiJodHRwczovL21hbmFnZW1lbnQuY29yZS53aW5kb3dzLm5ldC8iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9jYTE0ZThjYi03NzIzLTQ4MWUtOTUzYy0yNDY5NDBlNGQ5Y2YvIiwiaWF0IjoxNTcwNTcwOTY5LCJuYmYiOjE1NzA1NzA5NjksImV4cCI6MTU3MDU3NDg2OSwiYWNyIjoiMSIsImFpbyI6IkFXUUFtLzhOQUFBQTRnUHhzQjQ1bkl3cUc0b0JIc3oxTnFSYXRzdUlSL3daVE9YWHduWVlPMHpYYXIvY0FLZGh0WVdOZFZOSUdQL0dUMk9IQmhpMDhNSDloSFJ4L01RM2xIcUx2RkxONldwUTAzdVpKbTVHMjNQOFJYV3JiRVpMWXZKdUhSaEJjQlR3IiwiYWx0c2VjaWQiOiI1OjoxMDAzMDAwMEE2RTE4OUM2IiwiYW1yIjpbIndpYSJdLCJhcHBpZCI6ImM0NGI0MDgzLTNiYjAtNDljMS1iNDdkLTk3NGU1M2NiZGYzYyIsImFwcGlkYWNyIjoiMiIsImVtYWlsIjoicGhpbGlwLm1laG9sbUBhdGVhLm5vIiwiZ3JvdXBzIjpbImUzZWE1MDk4LTE1MDEtNGYwZS05ZmEwLThiNjdiNTdkNzRjNSIsIjEzZDE4NWVkLWQ3MDQtNGVjNi1hNTM0LTg1NzJlNzY5MGI5MiJdLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC82NWY1MTA2Ny03ZDY1LTRhYTktYjk5Ni00Y2M0M2EwZDcxMTEvIiwiaXBhZGRyIjoiMzEuNDUuMTA4LjUxIiwibmFtZSI6IlBoaWxpcCBNZWhvbG0iLCJvaWQiOiJlMGQ0ZjYwNy0yM2ZmLTRiMjctODUxNy1jMjQ3OTZhNWE0ZjEiLCJwdWlkIjoiMTAwMzNGRkZBQzg4NTNGRCIsInNjcCI6InVzZXJfaW1wZXJzb25hdGlvbiIsInN1YiI6IkZ1c1Jyd0NUNGFISHNKMWpHbmQ2SjlQYWJaRnMxSXVxRzVQTWVRLVBpaXciLCJ0aWQiOiJjYTE0ZThjYi03NzIzLTQ4MWUtOTUzYy0yNDY5NDBlNGQ5Y2YiLCJ1bmlxdWVfbmFtZSI6InBoaWxpcC5tZWhvbG1AYXRlYS5ubyIsInV0aSI6IjhsR0dHU005X2s2RXpmYjROTDBoQUEiLCJ2ZXIiOiIxLjAiLCJ3aWRzIjpbIjYyZTkwMzk0LTY5ZjUtNDIzNy05MTkwLTAxMjE3NzE0NWUxMCJdfQ.KPJo_vQt11Nw4MB-3_6nrccYhYfNDbQE34bCvbvBzstEspnWDTkC8fd8GBVJQnNrix0UcXYuoCBaxlrXxFNShEQyZC6sbghtAWm6MxTE7M2hjOE6oxd61DMeJxLRgM8EJrXleE9UAKpr2K8J_WFt80xcTu9lvgvDMjIrKh-ZolN9JfNjk-lmw1O03dzzbDzLRCugsSBzt-2rmAQ4PYyejHuaQAYJh4iueuDmERwx3EOYv6z0eB08se9hv5U0nXAEQWf-gXqycEdTXPzHX0naCXr4vpkLlmApTtc9kH_nf9nQU54kj-fHGt669-jwPXzxRUoRg33s6QN0_ArI4ByU5g"; 
#     "x-ms-effective-locale"="en.en-us"; 
#     "Accept"="*/*"; 
#     "x-ms-client-request-id"="5efda103-af17-4173-9289-a0cc7c346004"; 
#     "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.90 Safari/537.36"} 
#     -ContentType "application/json" 
#     -Body 
# @'
# {
#     "requests":[
#         {
#             "content":{
#                 "Name":"tetsi",
#                 "Type":"Microsoft.Storage/storageAccounts"
#             },
#             "httpMethod":"POST",
#             "requestHeaderDetails":{
#                 "commandName":"Microsoft_Azure_Storage.CreateStorageAccountHelper.validateStorageAccountNameForCreate"
#             },
#             "url":"https://management.azure.com/providers/microsoft.resources/checkresourcename?api-version=2015-11-01"
#         },
#         {
#             "content":{
#                 "name":"tetsi",
#                 "type":"Microsoft.Storage/storageAccounts"
#             },
#             "httpMethod":"POST",
#             "requestHeaderDetails":{
#                 "commandName":"Microsoft_Azure_Storage.StorageHelper.executeStorageNameCheck"
#             },
#             "url":"https://management.azure.com/subscriptions/675e4ea1-25ff-4c5d-a275-0dff8a4ab8be/providers/Microsoft.Storage/locations/westeurope/checkNameAvailability?api-version=2019-06-01`"
#         }
#     ]
# }
# '@
$header = @{
    Authorization="Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6ImFQY3R3X29kdlJPb0VOZzNWb09sSWgydGlFcyIsImtpZCI6ImFQY3R3X29kdlJPb0VOZzNWb09sSWgydGlFcyJ9.eyJhdWQiOiJodHRwczovL21hbmFnZW1lbnQuY29yZS53aW5kb3dzLm5ldC8iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9jYTE0ZThjYi03NzIzLTQ4MWUtOTUzYy0yNDY5NDBlNGQ5Y2YvIiwiaWF0IjoxNTcwNTcwOTY5LCJuYmYiOjE1NzA1NzA5NjksImV4cCI6MTU3MDU3NDg2OSwiYWNyIjoiMSIsImFpbyI6IkFXUUFtLzhOQUFBQTRnUHhzQjQ1bkl3cUc0b0JIc3oxTnFSYXRzdUlSL3daVE9YWHduWVlPMHpYYXIvY0FLZGh0WVdOZFZOSUdQL0dUMk9IQmhpMDhNSDloSFJ4L01RM2xIcUx2RkxONldwUTAzdVpKbTVHMjNQOFJYV3JiRVpMWXZKdUhSaEJjQlR3IiwiYWx0c2VjaWQiOiI1OjoxMDAzMDAwMEE2RTE4OUM2IiwiYW1yIjpbIndpYSJdLCJhcHBpZCI6ImM0NGI0MDgzLTNiYjAtNDljMS1iNDdkLTk3NGU1M2NiZGYzYyIsImFwcGlkYWNyIjoiMiIsImVtYWlsIjoicGhpbGlwLm1laG9sbUBhdGVhLm5vIiwiZ3JvdXBzIjpbImUzZWE1MDk4LTE1MDEtNGYwZS05ZmEwLThiNjdiNTdkNzRjNSIsIjEzZDE4NWVkLWQ3MDQtNGVjNi1hNTM0LTg1NzJlNzY5MGI5MiJdLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC82NWY1MTA2Ny03ZDY1LTRhYTktYjk5Ni00Y2M0M2EwZDcxMTEvIiwiaXBhZGRyIjoiMzEuNDUuMTA4LjUxIiwibmFtZSI6IlBoaWxpcCBNZWhvbG0iLCJvaWQiOiJlMGQ0ZjYwNy0yM2ZmLTRiMjctODUxNy1jMjQ3OTZhNWE0ZjEiLCJwdWlkIjoiMTAwMzNGRkZBQzg4NTNGRCIsInNjcCI6InVzZXJfaW1wZXJzb25hdGlvbiIsInN1YiI6IkZ1c1Jyd0NUNGFISHNKMWpHbmQ2SjlQYWJaRnMxSXVxRzVQTWVRLVBpaXciLCJ0aWQiOiJjYTE0ZThjYi03NzIzLTQ4MWUtOTUzYy0yNDY5NDBlNGQ5Y2YiLCJ1bmlxdWVfbmFtZSI6InBoaWxpcC5tZWhvbG1AYXRlYS5ubyIsInV0aSI6IjhsR0dHU005X2s2RXpmYjROTDBoQUEiLCJ2ZXIiOiIxLjAiLCJ3aWRzIjpbIjYyZTkwMzk0LTY5ZjUtNDIzNy05MTkwLTAxMjE3NzE0NWUxMCJdfQ.KPJo_vQt11Nw4MB-3_6nrccYhYfNDbQE34bCvbvBzstEspnWDTkC8fd8GBVJQnNrix0UcXYuoCBaxlrXxFNShEQyZC6sbghtAWm6MxTE7M2hjOE6oxd61DMeJxLRgM8EJrXleE9UAKpr2K8J_WFt80xcTu9lvgvDMjIrKh-ZolN9JfNjk-lmw1O03dzzbDzLRCugsSBzt-2rmAQ4PYyejHuaQAYJh4iueuDmERwx3EOYv6z0eB08se9hv5U0nXAEQWf-gXqycEdTXPzHX0naCXr4vpkLlmApTtc9kH_nf9nQU54kj-fHGt669-jwPXzxRUoRg33s6QN0_ArI4ByU5g"    
    commandName="Microsoft_Azure_Storage.CreateStorageAccountHelper.validateStorageAccountNameForCreate"
}

$body = @{
    "name"="tetsi"
    "type"="Microsoft.Storage/storageAccounts"
}
Invoke-restmethod  -Uri "https://management.azure.com/providers/microsoft.resources/checkresourcename?api-version=2015-11-01" -Headers $header -Body ($body|convertto-json) -Method Post -ContentType "application/json"