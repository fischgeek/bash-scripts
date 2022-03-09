#!/bin/bash

echo "$(tput setaf 3)!WARNING!$(tput sgr 0) This script is intended for $(tput setaf 3)NEW$(tput sgr 0) installations only."
read -p "Are you sure you want to contine? (y/n): " shouldContinue
if [ -z "$shouldContinue" ]
then
      echo "Invalid answer."
      exit 1
else
      if [ "$shouldContinue" == "n" ]
      then
            echo "Goodbye."
            exit 0
      else 
            echo "Moving on."
      fi
fi

if [ -z "$1" ]
then
      read -p "Site URL: " siteUrl
else
      echo "arg is $1"
      siteUrl="$1"
      echo "siteUrl is $siteUrl ($1)"
fi

echo "Running $0 on $siteUrl"

if [ -z "$siteUrl" ]
then
        echo "URL not provided."
        exit 1
else
        echo "URL provided."
fi

echo "Setting configuration options..."
wp option update default_comment_status ''
wp option update blogdescription ''
wp config set WP_HOME '$siteUrl'
wp config set WP_SITEURL '$siteUrl'
echo "Done."

echo "Removing unwanted content..."
wp post delete 1 --force  # the hello world post
wp post delete 2 --force  # the sample page

echo "Removing unwanted plugins..."
wp plugin deactivate hello
wp plugin deactivate akismet
wp plugin delete hello
wp plugin delete akismet
echo "Done."

echo "Creating Developer role..."
wp role create developer Developer
echo "Done."

echo "Configuring Developer role..."
function addCap {
      wp cap add developer $1
}
capArray=(
      "delete_others_pages" 
      "delete_others_posts" 
      "delete_pages" 
      "delete_posts" 
      "delete_private_pages" 
      "delete_private_posts" 
      "delete_published_pages" 
      "delete_published_posts" 
      "edit_others_pages" 
      "edit_others_posts" 
      "edit_pages" 
      "edit_posts" 
      "edit_private_pages" 
      "edit_private_posts " 
      "edit_published_pages" 
      "edit_published_posts" 
      "edit_theme_options" 
      "manage_categories" 
      "manage_links" 
      "publish_pages" 
      "publish_posts " 
      "read" 
      "read_private_pages" 
      "read_private_posts " 
      "unfiltered_html" 
      "upload_files"
)
for i in "${capArray[@]}"
do
      addCap $i
done
echo "Done."

echo "Adding users..."
wp user create kero-collab collab@kerocreative.com --role=developer
wp user create kero-kelsey kelsey@kerocreative.com --role=administrator
wp user create kero-tianna tianna@kerocreative.com --role=administrator
echo "Done."

echo "Installing and activating plugins..."
function autoPlug {
      wp plugin install $1
      wp plugin activate $1
      wp plugin auto-updates enable $1
}
pluginArray=(
      "contact-form-7" 
      "flamingo" 
      "branda-white-labeling" 
      "user-role-editor" 
      "wp-mail-smtp"
      "wordpress-seo"
)
for i in "${pluginArray[@]}"
do 
      autoPlug "$i"
done
wp plugin install wordfence
echo "Done."