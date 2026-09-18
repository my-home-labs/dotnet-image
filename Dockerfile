FROM mcr.microsoft.com/dotnet/sdk:10.0

# 1. Cài đặt công cụ hệ thống, Node.js, Java và RUBY (cho Fastlane)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    unzip \
    wget \
    curl \
    git \
    build-essential \
    ruby-full \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*
RUN curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --version 10.0.300 --install-dir /usr/share/dotnet
# 2. Cấu hình Locale (BẮT BUỘC cho Fastlane để tránh lỗi Encoding)
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# 3. Cài đặt Fastlane
RUN gem install fastlane -NV

# 4. Thiết lập biến môi trường Android & .NET
ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true
ENV DOTNET_NOLOGO=true
ENV ANDROID_HOME=/usr/lib/android-sdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# 5. Tải và cài đặt Android Command Line Tools
RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/tools.zip && \
    unzip /tmp/tools.zip -d $ANDROID_HOME/cmdline-tools && \
    mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest && \
    rm /tmp/tools.zip

# 6. Chấp nhận bản quyền và cài đặt SDK (Android 35/36 cho .NET 10)
RUN yes | sdkmanager --licenses && \
    sdkmanager --sdk_root=$ANDROID_HOME \
    "platform-tools" \
    "platforms;android-35" \
    "build-tools;35.0.0" \
    "platforms;android-36" \
    "build-tools;36.0.0"

# 7. Cài đặt MAUI Workloads
RUN dotnet workload install maui-android wasm-tools --no-cache && \
    dotnet workload update

WORKDIR /app
