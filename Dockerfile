FROM openjdk:11-jre-alpine

RUN apk update \
    && apk add \
        bash \
        libgomp \
        gcompat

ARG LANGUAGETOOL_VERSION="6.1-SNAPSHOT"

RUN mkdir /languagetool
WORKDIR /languagetool

COPY languagetool-standalone/target/LanguageTool-${LANGUAGETOOL_VERSION}/LanguageTool-${LANGUAGETOOL_VERSION}/ .
COPY entrypoint.sh .
COPY server.properties .

RUN addgroup -S languagetool && adduser -S languagetool -G languagetool
RUN chown -R languagetool.languagetool .
RUN chmod +x entrypoint.sh

USER languagetool

CMD [ "bash", "entrypoint.sh" ]

EXPOSE 8010

