FROM mcr.microsoft.com/dotnet/aspnet:5.0-buster-slim
WORKDIR /app
COPY OrderApiPublish .

ENTRYPOINT [ "dotnet", "OrderApi.dll" ]