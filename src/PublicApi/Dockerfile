FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS Build

WORKDIR /app
COPY . .

WORKDIR /app/src/PublicApi
RUN dotnet restore
RUN dotnet build
RUN dotnet publish -c Release -o /out

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim as Deploy
WORKDIR /app
COPY --from=Build /out .

ENTRYPOINT [ "dotnet", "PublicApi.dll" ]