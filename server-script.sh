sudo yum install java-11-amazon-corretto-headless.x86_64 -y
sudo yum install git -y
sudo yum install maven -y

if [ -d "addressbook-v1" ]
then
  echo "------------------repo is cloned and exists-----------------------------"
  cd addressbook-v1
  git pull origin jfrong-jenkin
else
  git clone https://github.com/rushikesh-pardeshi/addressbook-v1.git
fi


cd addressbook-v1
git checkout jfrong-jenkin
mvn package

# mvn -U deploy -s settings.xml
