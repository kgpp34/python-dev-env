FROM python:3.12-slim

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \
    UV_SYSTEM_PYTHON=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# 一次性安装依赖、配置镜像源、安装包并清理
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        git \
        && \
    # 安装uv
    pip install --no-cache-dir uv && \
    # 使用uv安装Python包
    uv pip install --system --no-cache \
        jupyterlab==4.0.* \
        pandas==2.* \
        numpy==1.* \
        matplotlib==3.* \
        requests==2.* \
        ipywidgets==8.* && \
    # 配置pip镜像源
    mkdir -p /etc && \
    echo -e "[global]\nindex-url=http://arti.cffex.net/api/pypi/pypi/simple/\n[install]\ntrusted-host=arti.cffex.net" > /etc/pip.conf && \
    # 配置uv镜像源
    mkdir -p /root/.config/uv && \
    echo -e 'index-url = "http://arti.cffex.net/api/pypi/pypi/simple/"\nallow-insecure-host = ["arti.cffex.net"]' > /root/.config/uv/uv.toml && \
    # 清理apt缓存和临时文件
    apt-get purge -y --auto-remove curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache

# 创建非root用户
RUN useradd -m -u 1000 jupyter && \
    mkdir -p /workspace && \
    chown -R jupyter:jupyter /workspace

# 切换到非root用户
USER jupyter
WORKDIR /workspace

# 暴露端口
EXPOSE 8888

# 启动命令
CMD ["jupyter", "lab", \
     "--ip=0.0.0.0", \
     "--port=8888", \
     "--no-browser", \
     "--ServerApp.token=''", \
     "--ServerApp.password=''", \
     "--ServerApp.allow_root=False"]
