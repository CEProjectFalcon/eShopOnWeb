FROM mcr.microsoft.com/dotnet/aspnet:5.0-buster-slim
WORKDIR /app
COPY WebPublish .

ENTRYPOINT [ "dotnet", "Web.dll" ]