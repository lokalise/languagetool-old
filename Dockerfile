FROM debian:bullseye AS patch

ARG LANGUAGETOOL_VERSION="6.1-SNAPSHOT"

# Install tools required for the workaround scripts
RUN apt-get update -y && apt-get install -y build-essential cmake git wget zip unzip maven mercurial texlive locales bash libgomp1 openjdk-11-jdk-headless git maven

RUN mkdir -p /dist/LanguageTool

COPY languagetool-standalone/target/LanguageTool-${LANGUAGETOOL_VERSION}/LanguageTool-${LANGUAGETOOL_VERSION}/ /dist/LanguageTool/

WORKDIR /
COPY build/arm64-workaround/bridj.sh arm64-workaround/bridj.sh
RUN chmod +x arm64-workaround/bridj.sh
RUN bash -c "arm64-workaround/bridj.sh"

COPY build/arm64-workaround/hunspell.sh arm64-workaround/hunspell.sh
RUN chmod +x arm64-workaround/hunspell.sh
RUN bash -c "arm64-workaround/hunspell.sh"

FROM alpine:3.17.3

RUN apk add --no-cache \
    bash \
    curl \
    libc6-compat \
    libstdc++ \
    openjdk11-jre-headless

# https://github.com/Erikvl87/docker-languagetool/issues/60
RUN ln -s /lib64/ld-linux-x86-64.so.2 /lib/ld-linux-x86-64.so.2

RUN mkdir /languagetool
WORKDIR /languagetool

COPY --from=patch /dist/LanguageTool .
COPY entrypoint.sh .
COPY server.properties .

RUN addgroup -S languagetool && adduser -S languagetool -G languagetool
RUN chown -R languagetool.languagetool .
RUN chmod +x entrypoint.sh

USER languagetool

CMD [ "bash", "entrypoint.sh" ]

EXPOSE 8010
