FROM python:3.12-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONUNBUFFERED=1
ENV UV_SYSTEM_PYTHON=1

# 更新系统包并安装必要的依赖
RUN apt-get update && \
    apt-get install -y \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 安装 uv 包管理器
RUN pip install uv

# 配置 pip.conf
RUN mkdir -p /etc && \
    echo "[global]" > /etc/pip.conf && \
    echo "index-url=http://arti.cffex.net/api/pypi/pypi/simple/" >> /etc/pip.conf && \
    echo "[install]" >> /etc/pip.conf && \
    echo "trusted-host=arti.cffex.net" >> /etc/pip.conf

# 为uv配置相同的镜像源
RUN mkdir -p /root/.config/uv && \
    echo "[global]" > /root/.config/uv/uv.toml && \
    echo 'index-url = "http://arti.cffex.net/api/pypi/pypi/simple/"' >> /root/.config/uv/uv.toml && \
    echo 'trusted-host = ["arti.cffex.net"]' >> /root/.config/uv/uv.toml

# 使用uv安装Jupyter Lab和常用科学计算包
RUN uv pip install --system \
    jupyterlab \
    notebook \
    pandas \
    numpy \
    matplotlib \
    seaborn \
    scikit-learn \
    requests \
    ipywidgets

# 创建工作目录
RUN mkdir -p /workspace
WORKDIR /workspace

# 暴露Jupyter Lab端口
EXPOSE 8888

# 启动Jupyter Lab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''"]
