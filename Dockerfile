FROM ubuntu:18.10 as vim_builder

RUN apt-get update -qq && apt-get upgrade -y && apt-get install -qq -y \
    git \
    build-essential \
    liblua5.1-dev \
    luajit \
    libluajit-5.1 \
    python-dev \
    python3-dev \
    ruby-dev \
    ruby2.5 \
    ruby2.5-dev \
    libperl-dev \
    libncurses5-dev \
    libatk1.0-dev \
    libx11-dev \
    libxpm-dev \
    libxt-dev \
    libc6-dev \
    --no-install-recommends

RUN git clone https://github.com/vim/vim.git

RUN cd vim && \
    ./configure \
    --with-features=huge \
    --enable-multibyte \
    --enable-rubyinterp=yes \
    --enable-pythoninterp=yes \
    --with-python-config-dir=/usr/lib/python2.7/config \
    --enable-python3interp=yes \
    --with-python3-config-dir=/usr/lib/python3.5/config \
    --enable-perlinterp=yes \
    --enable-luainterp=yes \
    --enable-gui=gtk2 \
    --enable-cscope \
    --prefix=/usr/local && \
    make install

FROM ubuntu:18.10

COPY --from=vim_builder /usr/local/bin /usr/local/bin
COPY --from=vim_builder /usr/local/share/vim /usr/local/share/vim

RUN apt-get update -qq && apt-get upgrade -y && apt-get install -qq -y \
    sudo \
    curl \
    wget \
    git \
    zip \
    tig \
    zsh \
    ripgrep \
    tree \
    mosh \
    openssh-server \
    ca-certificates \
    python-dev \
    python3-dev \
    ruby2.5 \
    libx11-dev \
    libxpm-dev \
    libxt-dev \
    libc6-dev

RUN useradd -ms /bin/bash jfree
RUN usermod -aG sudo jfree

RUN mkdir /run/sshd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed 's/#Port 22/Port 3222/' -i /etc/ssh/sshd_config

# Install anitgen for zsh
RUN mkdir -p /usr/local/share/antigen/ && \
    curl -L git.io/antigen > /usr/local/share/antigen/antigen.zsh

# Better git diffing
RUN curl "https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy" > /usr/bin/diff-so-fancy && \
  chmod +x /usr/bin/diff-so-fancy

# Set zsh as default shell
RUN chsh -s $(which zsh)

USER jfree
WORKDIR /home/jfree

# Git setup
# @todo Place this in gitconfig file in dotfiles repo
RUN git config --global user.email "mail@jayfreestone.com" && \
  git config --global user.name "Jay Freestone" && \
  git config --global core.pager "diff-so-fancy"

# Avoids prompt for known hosts on first clone/connect
RUN mkdir ~/.ssh/
RUN ssh-keyscan -H github.com >> ~/.ssh/known_hosts

# @todo We should use and clean up the link script on the dotfiles repo
RUN git clone https://github.com/jayfreestone/dotfiles && \
  ln -s ~/dotfiles/zshrc ~/.zshrc
RUN git clone https://github.com/jayfreestone/vim && \
  ln -s ~/vim/vimrc ~/.vimrc
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
  ~/.fzf/install

EXPOSE 3222 60000-60010/udp
CMD ["/usr/sbin/sshd", "-D"]
