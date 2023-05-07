FROM dart:2.19.6-sdk

WORKDIR /app

ADD . /app/
RUN dart pub get
RUN dart pub global activate conduit 4.3.9
EXPOSE 6200

ENTRYPOINT [ "dart","pub","run","conduit:conduit","serve","--port","6200" ]