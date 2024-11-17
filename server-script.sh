# sudo yum install java-1.8.0-openjdk-devel -y
sudo yum install git -y
# sudo yum install maven -y
sudo yum install docker -y
sudo systemctl start docker

if [ -d "addressbook-v1" ]
then
  echo "------------------repo is cloned and exists-----------------------------"
  cd addressbook-v1
  git pull origin ssh-agent
else
echo "--------------------clone git repo-----------------------------------------"
  git clone https://github.com/rushikesh-pardeshi/addressbook-v1.git
fi


cd addressbook-v1
git checkout ssh-agent
mvn package

sudo docker build -t $1 .

