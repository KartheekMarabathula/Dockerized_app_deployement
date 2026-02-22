#stage 1    taking a base image of python 3.9 slim and naming it as builder
FROM python:3.9-slim AS builder

#creating a working directory to store code files
WORKDIR /app

#installing dependencies for mysqlclient and cleaning up apt cache to reduce image size
#mysqlclient library is in c++ and needs to be compiled, so we need to install -
#the necessary development libraries and tools like gcc and pkg-config. so added these RUN
#command.
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

#copying the requirements.txt file to the working directory
COPY requirements.txt .

#and installing the python dependencies specified in the requirements.txt file using pip.
# The --no-cache-dir option is used to prevent pip from caching -
#the installed packages, which helps to reduce the image size.
# The --user option is used to install the packages in the user's home directory, 
#which is necessary because we are running this command in a non-root environment 
#in the builder stage. This allows us to avoid permission issues when installing packages
# and also helps to keep the image clean by not installing packages globally.
RUN pip install --user --no-cache-dir -r requirements.txt

#stage 2    taking a base image of python 3.9 slim and creating a new stage for the final image
FROM python:3.9-slim

#setting the working directory to /app where the application code will be stored
WORKDIR /app

#installing the necessary runtime dependencies for mysqlclient and cleaning up apt cache 
#to reduce image size. we dont need to install gcc and pkg-config in this stage because 
#we are not compiling anything here, we just need the runtime libraries for mysqlclient.
RUN apt-get update && apt-get install -y --no-install-recommends \
    default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

#copying the installed python packages from the builder stage to the final image.
COPY --from=builder /root/.local /root/.local

#copying the application code from the current directory to the working directory 
#in the final image.
COPY . .

#setting the PATH environment variable to include the directory where pip installs packages, 
#so that the installed packages can be found and used when the container is run.
ENV PATH=/root/.local/bin:$PATH

#exposing port 5000 for the application to listen on
EXPOSE 5000

# setting the default command to run the application using python app.py when the 
#container is started.
CMD ["python", "app.py"]

