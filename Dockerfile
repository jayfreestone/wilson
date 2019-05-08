FROM ubuntu:18.10 as base
RUN apt-get update -qq && apt-get upgrade -y && apt-get install -qq -y \
    sudo \
    curl \
    wget \
    git \
    zip \
    tig \
    zsh \
    ripgrep \
    openssh-server \
    ca-certificates \
    --no-install-recommends
RUN apt-get install -qq -y \
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
	   --prefix=/usr/local \
    && make install

# FROM base as vim_build

FROM base as user_setup
RUN useradd -ms /bin/bash jfree
RUN usermod -aG sudo jfree
RUN chsh -s $(which zsh)

FROM user_setup as ssh_setup
ARG SSH_KEY
# Needs root privileges
RUN mkdir /run/sshd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed 's/#Port 22/Port 3222/' -i /etc/ssh/sshd_config
# @todo: Should we be switching user at all?
USER jfree
RUN mkdir ~/.ssh/
RUN echo "$SSH_KEY" > ~/.ssh/id_rsa
RUN chmod 600 ~/.ssh/id_rsa
RUN echo "$SSH_PUBLIC_KEY" > ~/.ssh/authorized_keys
RUN chmod 600 ~/.ssh/authorized_keys
RUN eval `ssh-agent -s` && ssh-add ~/.ssh/id_rsa
# Avoids prompt for known hosts on first clone/connect
RUN ssh-keyscan -H github.com >> ~/.ssh/known_hosts
# RUN sed -i /etc/ssh/sshd_config \
        # -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
        # -e 's/#PasswordAuthentication.*/PasswordAuthentication no/'

FROM ssh_setup as config_setup
# Install anitgen for zsh
USER root
RUN apt-get update -qq && apt-get upgrade -y && apt-get install -qq -y libc6-dev
RUN mkdir -p /usr/local/share/antigen/ && \
    curl -L git.io/antigen > /usr/local/share/antigen/antigen.zsh
# Better git diffing
RUN curl "https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy" > /usr/bin/diff-so-fancy && \
  chmod +x /usr/bin/diff-so-fancy
USER jfree
WORKDIR /home/jfree
RUN git config --global user.email "mail@jayfreestone.com" && \
  git config --global user.name "Jay Freestone" && \
  git config --global core.pager "diff-so-fancy"
# @todo We should use and clean up the link script on the dotfiles repo
RUN git clone git@github.com:jayfreestone/dotfiles.git && \
  ln -s ~/dotfiles/zshrc ~/.zshrc
RUN git clone git@github.com:jayfreestone/vim.git && \
  ln -s ~/vim/vimrc ~/.vimrc
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
  ~/.fzf/install

COPY entrypoint.sh /bin/entrypoint.sh
ENTRYPOINT ["sh", "/bin/entrypoint.sh"]