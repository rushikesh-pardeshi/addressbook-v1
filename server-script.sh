sudo yum install java-11-amazon-corretto-headless.x86_64 -y
sudo yum install git -y
sudo yum install maven -y

if [ -d "addressbook-v1" ]
then
  echo "repo is cloned and exists"
  cd addressbook-v1
  git pull origin ssh-agent
else
  git clone https://github.com/rushikesh-pardeshi/addressbook-v1.git
  git checkout ssh-agent
fi

cd addressbook-v1

mvn package