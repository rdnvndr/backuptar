#!/bin/sh

ARCNAME=roandsystem
MAILADDR=root@localhost
HOSTNAME=Roand-System
REPODIR="/home/common/backup"
SNARDIR="$REPODIR/snar"
UNDODIR="$REPODIR/undo"
# BKLIST=`cat /etc/backup/backup.lst | awk '// {print substr($0,2,length($0)-1)}'| tr "\n" " "`
BKLIST=`cat /etc/backup/backup.lst | awk '// {if (length($0)>1){ print substr($0,2,length($0)-1)} else {if($0!=" "&&$0!=""){print "."}} }'| tr "\n" " "` 
BKEXCLUDE=`cat /etc/backup/backup-exclude.lst | awk '// {print " --exclude=" substr($0,2,length($0)-1)}'|tr "\n" " "`

export LANG=ru_RU.UTF-8

tar_up(){
   # $1 - level
   # $2 - path
   # $3 - tarball
   cd /
   tar -cJf $REPODIR/$ARCNAME-$1.tar.xz $BKEXCLUDE --listed-incremental $SNARDIR/$ARCNAME.snar $BKLIST 2>>/tmp/backup_script_tmpfile
   cp $SNARDIR/$ARCNAME.snar $SNARDIR/$ARCNAME-$1.snar
   RETVAL=$?
   return $RETVAL
}

run_full_backup(){
   # $1 - path
   # $2 - tarball
   rm -f $SNARDIR/$ARCNAME.snar
   tar_up `date "+%F"`"-full"
}

# run_backup <path-to-backup> <tarball-name> <extra-arguments[optional]>
# eg:

echo "Отчет о резервном копировании на $HOSTNAME " > /tmp/backup_script_tmpfile
echo >> /tmp/backup_script_tmpfile
echo "Копирование начато в `date +%H:%M:%S`, `date +%A`, `date +%d` `date +%B` `date +%Y`:" >> /tmp/backup_script_tmpfile
echo >> /tmp/backup_script_tmpfile


if [ ! -d $REPODIR ];then
   mkdir -p $REPODIR
fi
if [ ! -d $SNARDIR ];then
   mkdir -p $SNARDIR
fi

YEAR=`date '+%Y'`
ISYEAR=`ls -r ${REPODIR} | grep -m 1 -e ${ARCNAME}-${YEAR}-.*full.tar.xz` 
if [ "$ISYEAR" = "" ];then
   run_full_backup $BKLIST $ARCNAME
   echo "## Создан полный архив ##" >> /tmp/backup_script_tmpfile
   echo  $REPODIR/$ARCNAME-`date "+%F"`-full.tar.xz >> /tmp/backup_script_tmpfile
   echo -e "\n" >> /tmp/backup_script_tmpfile
   echo "## Пути для архивирования ##">> /tmp/backup_script_tmpfile
   cat /etc/backup/backup.lst >> /tmp/backup_script_tmpfile
   echo -e "\n" >> /tmp/backup_script_tmpfile
   echo "## Пути для исключения ##">> /tmp/backup_script_tmpfile
   cat /etc/backup/backup-exclude.lst >> /tmp/backup_script_tmpfile
   echo -e "\n" >> /tmp/backup_script_tmpfile
else

YEARMONTH=`date '+%Y-%m'`
ISMONTH=`ls -r ${REPODIR} | grep -m 1 -e ${ARCNAME}-${YEARMONTH}-.*month.tar.xz;ls -r ${REPODIR} | grep -m 1 -e ${ARCNAME}-${YEARMONTH}-.*full.tar.xz`
if [ "$ISMONTH" = "" ];then
   OLDSNAR=`ls -r ${SNARDIR} | grep -m 1 -e ${ARCNAME}-.*month.snar`
   if [ "$OLDSNAR" = "" ];then
       OLDSNAR=`ls -r ${SNARDIR} | grep -m 1 -e ${ARCNAME}-.*full.snar`
   fi
   cp $SNARDIR/$OLDSNAR $SNARDIR/$ARCNAME.snar 
   tar_up `date "+%F"`"-month" $BKLIST $ARCNAME"
   echo "## Создан месячный архив ##" >> /tmp/backup_script_tmpfile
   echo  $REPODIR/$ARCNAME-`date "+%F"`-month.tar.xz >> /tmp/backup_script_tmpfile
   echo -e "\n" >> /tmp/backup_script_tmpfile
   echo "## Пути для архивирования ##">> /tmp/backup_script_tmpfile
   cat /etc/backup/backup.lst >> /tmp/backup_script_tmpfile
   echo -e "\n" >> /tmp/backup_script_tmpfile
   echo "## Пути для исключения ##">> /tmp/backup_script_tmpfile
   cat /etc/backup/backup-exclude.lst >> /tmp/backup_script_tmpfile
   echo -e "\n" >> /tmp/backup_script_tmpfile
   ls $REPODIR/$ARCNAME-????-??-??-week*.tar.xz 2> /dev/null | xargs rm 2>/dev/null
   ls $REPODIR/$ARCNAME-????-??-??.tar.xz 2> /dev/null | xargs rm  2>/dev/null
   ls $SNARDIR/$ARCNAME-????-??-??-week*.snar 2> /dev/null | xargs rm 2>/dev/null
   ls $SNARDIR/$ARCNAME-????-??-??.snar 2> /dev/null | xargs rm  2>/dev/null
else

WEEK=`date '+%U'`
ISWEEK=`ls -r ${REPODIR} | grep -m 1 -e ${ARCNAME}-.*week${WEEK}.tar.xz`
if [ "$ISWEEK" = "" ];then
   OLDSNAR=`ls -r ${SNARDIR} | grep -m 1 -e ${ARCNAME}-.*week*.snar`
   if [ "$OLDSNAR" = "" ];then
       OLDSNAR=`ls -r ${SNARDIR} | grep -m 1 -e ${ARCNAME}-.*month.snar`
   fi
   if [ "$OLDSNAR" = "" ];then
       OLDSNAR=`ls -r ${SNARDIR} | grep -m 1 -e ${ARCNAME}-.*full.snar`
   fi
   cp $SNARDIR/$OLDSNAR $SNARDIR/$ARCNAME.snar 
   tar_up `date "+%F"`"-week$WEEK" $BKLIST $ARCNAME"
   echo "## Создан месячный архив ##" >> /tmp/backup_script_tmpfile
   echo  $REPODIR/$ARCNAME-`date "+%F"`-month.tar.xz >> /tmp/backup_script_tmpfile
   echo -e "\n" >> /tmp/backup_script_tmpfile
   echo "## Пути для архивирования ##">> /tmp/backup_script_tmpfile
   cat /etc/backup/backup.lst >> /tmp/backup_script_tmpfile
   echo -e "\n" >> /tmp/backup_script_tmpfile
   echo "## Пути для исключения ##">> /tmp/backup_script_tmpfile
   cat /etc/backup/backup-exclude.lst >> /tmp/backup_script_tmpfile
   echo -e "\n" >> /tmp/backup_script_tmpfile
   ls $REPODIR/$ARCNAME-????-??-??.tar.xz 2> /dev/null | xargs rm 2> /dev/null
   ls $SNARDIR/$ARCNAME-????-??-??.snar 2> /dev/null | xargs rm  2>/dev/null
else


YEARMONTHDAY=`date '+%F'`
ISDAY=`ls -r ${REPODIR} | grep -m 1 -e ${ARCNAME}-${YEARMONTHDAY}*.tar.xz`
if [ "$ISDAY" = "" ];then
   tar_up `date "+%F"` $BKLIST $ARCNAME
   echo "## Создан инкрементальный архив ##" >> /tmp/backup_script_tmpfile
   echo  $REPODIR/$ARCNAME-`date "+%F"`.tar.xz >> /tmp/backup_script_tmpfile
   echo -e "\n" >> /tmp/backup_script_tmpfile
   echo "## Пути для архивирования ##">> /tmp/backup_script_tmpfile
   cat /etc/backup/backup.lst >> /tmp/backup_script_tmpfile
   echo -e "\n" >> /tmp/backup_script_tmpfile
   echo "## Пути для исключения ##">> /tmp/backup_script_tmpfile
   cat /etc/backup/backup-exclude.lst >> /tmp/backup_script_tmpfile
   echo -e "\n" >> /tmp/backup_script_tmpfile
else   
  echo "Backup сегодня уже создан"
   exit;
fi

fi
fi
fi


echo "Копирование завершено в `date +%H:%M:%S`, `date +%A`, `date +%d` `date +%B` `date +%Y`" >> /tmp/backup_script_tmpfile

# Вариант отправки почты
# mail  -s "$HOSTNAME backup report of `date +%d-%m-%y`" $MAILADDR < /tmp/backup_script_tmpfile

/usr/bin/sendmail -t <<ERRMAIL
To: $MAILADDR
From: systemd <root@$HOSTNAME>
Subject: $HOSTNAME backup report of `date +%d-%m-%y`
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
$(cat /tmp/backup_script_tmpfile)
ERRMAIL

rm -f /tmp/backup_script_tmpfile


