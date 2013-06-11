KITCHEN_DIR="${PWD}/.kitchen"
export GEM_HOME="~/.gem"
export PATH="~/.gem/bin:$PATH"

if [ ! -f $KITCHEN_DIR/prepared ]
then
    vagrant plugin install berkshelf-vagrant || exit 1
    gem install berkshelf || exit 1
    gem install kitchen-vagrant || exit 1
    gem install test-kitchen --pre || exit 1
    mkdir -p $KITCHEN_DIR
    touch $KITCHEN_DIR/prepared
fi

foodcritic -f ~FC007 . || exit 1
knife cookbook test -o .. $(basename $PWD) || exit 1
kitchen test
