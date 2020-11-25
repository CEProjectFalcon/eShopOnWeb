FROM mcr.microsoft.com/dotnet/sdk:5.0-buster-slim AS Build

WORKDIR /app
COPY . .

WORKDIR /app/src/Web
RUN dotnet restore
RUN dotnet build
RUN dotnet publish -c Release -o /out

FROM mcr.microsoft.com/dotnet/aspnet:5.0-buster-slim as Deploy
WORKDIR /app
COPY --from=Build /out .

ENTRYPOINT [ "dotnet", "Web.dll" ]