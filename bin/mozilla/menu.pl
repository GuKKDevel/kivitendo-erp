#=====================================================================
# LX-Office ERP
# Copyright (C) 2004
# Based on SQL-Ledger Version 2.1.9
# Web http://www.lx-office.org
#
######################################################################
# SQL-Ledger Accounting
# Copyright (c) 1998-2002
#
#  Author: Dieter Simader
#   Email: dsimader@sql-ledger.org
#     Web: http://www.sql-ledger.org
#
#  Contributors: Christopher Browne
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#######################################################################
#
# the frame layout with refractured menu
#
# CHANGE LOG:
#   DS. 2002-03-25  Created
#  2004-12-14 - New Optik - Marco Welter <mawe@linux-studio.de>
#  2010-08-19 - Icons for sub entries and single click behavior, unlike XUL-Menu
#               JS switchable HTML-menu - Sven Donath <lxo@dexo.de>
#######################################################################

use strict;

use SL::Menu;
use URI;

use List::MoreUtils qw(apply);

sub render {
  $::lxdebug->enter_sub;

  $::form->use_stylesheet(qw(css/icons16.css css/icons24.css));

  my $menu         = Menu->new("menu.ini");

  my $sections = [ section_menu($menu) ];

  $::lxdebug->leave_sub;
  $::form->parse_html_template('menu/menu', {
    sections  => $sections,
    inline    => 1,
  });
}

sub section_menu {
  $::lxdebug->enter_sub(2);
  my ($menu, $level, $id_prefix) = @_;
  my @menuorder = $menu->access_control(\%::myconfig, $level);
  my @items;

  my $id = 0;

  for my $item (@menuorder) {
    my $menuitem   = $menu->{$item};
    my $olabel     = apply { s/.*--// } $item;
    my $ml         = apply { s/--.*// } $item;
    my $icon_class = apply { y/ /-/   } $item;
    my $spacer     = "s" . (0 + $item =~ s/--/--/g);

    next if $level && $item ne "$level--$olabel";

    my $label         = $::locale->text($olabel);

    $menuitem->{module} ||= $::form->{script};
    $menuitem->{action} ||= "section_menu";
    $menuitem->{href}   ||= "$menuitem->{module}?action=$menuitem->{action}";

    # add other params
    foreach my $key (keys %$menuitem) {
      next if $key =~ /target|module|action|href/;
      $menuitem->{href} .= "&" . $::form->escape($key, 1) . "=";
      my ($value, $conf) = split(/=/, $menuitem->{$key}, 2);
      $value = $::myconfig{$value} . "/$conf" if ($conf);
      $menuitem->{href} .= $::form->escape($value, 1);
    }

    my $anchor = $menuitem->{href};

    my %common_args = (
        l   => $label,
        s  => $spacer,
        id => "$id_prefix\_$id",
    );

    if (!$level) { # toplevel
      push @items, { %common_args,
        i      => "icon24 $icon_class",   #  make_image(size => 24, label => $item),
        c    => 'm',
      };
      push @items, section_menu($menu, $item, "$id_prefix\_$id");
    } elsif ($menuitem->{submenu}) {
      push @items, { %common_args,
        i      => "icon16 submenu",   #make_image(label => 'submenu'),
        c    => 'sm',
      };
      push @items, section_menu($menu, $item, "$id_prefix\_$id");
    } elsif ($menuitem->{module}) {
      push @items, { %common_args,
        i     => "icon16 $icon_class",  #make_image(size => 16, label => $item),
        h    => $anchor,
        c   => 'i',
      };
    }
  } continue {
    $id++;
  }

  $::lxdebug->leave_sub(2);
  return @items;
}

sub _calc_framesize {
  my $is_lynx_browser   = $ENV{HTTP_USER_AGENT} =~ /links/i;
  my $is_mobile_browser = $ENV{HTTP_USER_AGENT} =~ /mobile/i;
  my $is_mobile_style   = $::form->{stylesheet} =~ /mobile/i;

  return  $is_mobile_browser && $is_mobile_style ?  130
        : $is_lynx_browser                       ?  240
        :                                           200;
}

sub _show_images {
  # don't show images in links
  _calc_framesize() != 240;
}

1;

__END__
