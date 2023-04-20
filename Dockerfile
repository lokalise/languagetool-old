FROM debian:bullseye AS patch

RUN mkdir /dist/Languagetool
WORKDIR /dist/Languagetool

COPY languagetool-standalone/target/LanguageTool-${LANGUAGETOOL_VERSION}/LanguageTool-${LANGUAGETOOL_VERSION}/ .

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

ARG LANGUAGETOOL_VERSION="6.1-SNAPSHOT"

RUN mkdir /languagetool
WORKDIR /languagetool

COPY --from=patch /dist/Languagetool .
COPY entrypoint.sh .
COPY server.properties .

RUN addgroup -S languagetool && adduser -S languagetool -G languagetool
RUN chown -R languagetool.languagetool .
RUN chmod +x entrypoint.sh

USER languagetool

CMD [ "bash", "entrypoint.sh" ]

EXPOSE 8010

