ADB = ${ANDROID_HOME}/platform-tools/adb
EMULATOR = ${ANDROID_HOME}/tools/emulator
GRADLEW = ./gradlew --daemon --parallel --stacktrace

ifdef ComSpec	 # Windows
  # Use `/` for all paths, except `.\`
  ADB := $(subst \,/,${ADB})
  EMULATOR := $(subst \,/,${EMULATOR})
  GRADLEW := $(subst /,\,${GRADLEW})
endif

.PHONY: default assets clean test deploy emulator kill logs prod

default: clean deploy logs
prod: clean deploy

clean:
	rm -rf src/main/assets/
	rm -rf build/

test:
	${GRADLEW} check test connectedCheck

emulator:
	nohup ${EMULATOR} -avd test -wipe-data > emulator.log 2>&1 &
	${ADB} wait-for-device

logs:
	${ADB} logcat MedicGateway:V AndroidRuntime:E *:S | tee android.log

deploy:
	${GRADLEW} installDebug

kill:
	pkill -9 emulator64-arm


.PHONY: demo-server

demo-server:
	npm install && npm start


.PHONY: stats travis

stats:
	./scripts/project_stats

travis: stats
	${GRADLEW} check test assemble
	./scripts/start_emulator
	${GRADLEW} connectedCheck
