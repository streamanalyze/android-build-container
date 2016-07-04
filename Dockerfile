FROM debian:8
MAINTAINER Martin Holmin <martin@streamanalyze.com>

ENV ANDROID_SDK_URL="https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz" \
    ANDROID_BUILD_TOOLS_VERSION=23.0.3 \
    ANDROID_APIS="android-10,android-15,android-16,android-17,android-18,android-19,android-20,android-21,android-22,android-23" \
    ANT_HOME="/usr/share/ant" \
    ANT_HOME="/usr/share/ant" \
    MAVEN_HOME="/usr/share/maven" \
    GRADLE_HOME="/usr/share/gradle" \
    ANDROID_HOME="/opt/android-sdk-linux" \
    ANDROID_NDK_HOME="/opt/android-ndk" \
    LANG="C.UTF-8" \
    JAVA_HOME="/usr/lib/jvm/java-8-oracle"

RUN \
  dpkg --add-architecture i386 && \
  echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list && \
  echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list && \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && \
  apt-get -qq update && \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  apt-get install -y oracle-java8-installer && \
  apt-get install -y curl git unzip wget && \
  apt-get install -y libncurses5:i386 libstdc++6:i386 zlib1g:i386 gcc-multilib build-essential && \

  # Clean up
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /var/cache/oracle-jdk8-installer

ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$ANDROID_NDK_HOME:$ANT_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin

RUN \
  apt-get update && \
  apt-get install -y ant gradle && \

  # Install Android SDK
  curl -sL ${ANDROID_SDK_URL} | tar xz -C /opt && \
  echo y | android update sdk -a -u -t platform-tools,${ANDROID_APIS},build-tools-${ANDROID_BUILD_TOOLS_VERSION} && \
  chmod a+x -R $ANDROID_HOME && \
  chown -R root:root $ANDROID_HOME && \

  # Install Android NDK
  mkdir -p /opt/android-ndk-tmp && \
  cd /opt/android-ndk-tmp && wget -q http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin && \
  cd /opt/android-ndk-tmp && chmod a+x /opt/android-ndk-tmp/android-ndk-r10e-linux-x86_64.bin && \
  cd /opt/android-ndk-tmp && ./android-ndk-r10e-linux-x86_64.bin && \
  cd /opt/android-ndk-tmp && mv ./android-ndk-r10e /opt/android-ndk && \

  # Clean up
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  rm -rf /opt/android-ndk-tmp && \
  apt-get autoremove -y && \
  apt-get clean

CMD ["/bin/bash"]
