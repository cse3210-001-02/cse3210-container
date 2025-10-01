FROM debian:bookworm-slim

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ARG USERNAME=cse3210
ARG USER_UID=1000
ARG USER_GID=$USER_UID


RUN apt-get update && apt-get install -y \
    && apt-get install -y sudo curl git unzip wget lsb-release software-properties-common gnupg \
    && rm -rf /var/lib/apt/lists/*

# create user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL >/etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME

# ninja
RUN curl -fSL https://github.com/ninja-build/ninja/releases/download/v1.13.1/ninja-linux.zip -o /tmp/ninja-linux.zip \
    && sudo unzip /tmp/ninja-linux.zip -d /usr/local/bin \
    && rm -f /tmp/ninja-linux.zip

# clang
RUN wget -O /tmp/llvm.sh https://apt.llvm.org/llvm.sh \
    && chmod +x /tmp/llvm.sh \
    && sudo /tmp/llvm.sh 21 \
    && sudo apt install -y clang-format-21 \
    && sudo ln -s /usr/bin/clang-21 /usr/bin/cc \
    && sudo ln -s /usr/bin/clang++-21 /usr/bin/c++ \
    && sudo ln -s /usr/bin/clangd-21 /usr/bin/clangd \
    && sudo ln -s /usr/bin/clang-format-21 /usr/bin/clang-format \
    && rm -f /tmp/llvm.sh
ENV CC=clang-21 CXX=clang++-21

# meson
RUN uv tool install meson
ENV PATH="/home/$USERNAME/.local/bin:$PATH"
