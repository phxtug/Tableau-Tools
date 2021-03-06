#  Copyright (C) 2014, 2015  Chris Gerrard
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'twb'

system "cls"

$doctwb      = true
$replacetwb  = false                      # true|false - replace/new name TWB
$dashdoclbl  = 'dashdoc'
$localurl    = 'file:///' + Dir.pwd + '/' # for Dashboard Web Page objects

  def xray twbname
    twb    = Twb::Workbook.new(twbname)
    xrayer = Twb::DashboardXRayer.new(twb)
    xrays  = xrayer.xray
    cnt    = 0
    xrays.each do |dash, html|
      htmlfilename =  twb.name + '.' + dash.to_s  + '.html'
      saveHTML(htmlfilename, html)
      cnt += 1
      if $doctwb
        inject(twb, dash.to_s, htmlfilename)
      end
    end
    puts "\t    #{cnt} \t       #{twbname}"
  end

  def saveHTML(htmlfilename, html)
    begin
      htmlfile = File.open(htmlfilename, 'w')
      htmlfile.puts html
      htmlfile.close
    rescue
      # Common failure is when the Dashboard name contains
      # invalid file name Characters. or when the name is
      # an invalid file name.
      # Stripping the non-ASCII characters from the Dashboard
      # name fixes this, in the cases seen so far.
      # This rescue-recursion technique can potentially cause
      # an infite-loop condition. (not seen, but possible)
      saveHTML( sanitize(htmlfilename), html)
    end
  end

  def inject(twb, dashboard, htmlfilename)
    vDash = Twb::DocDashboardWebVert.new
    vDash.title=('Doc Dashboard: ' + sanitize(dashboard))
    vDash.url=($localurl  + '/' + htmlfilename)
    twb.addDocDashboard(vDash)
    if $replacetwb
      twb.write
    else
      twb.writeAppend($dashdoclbl)
    end
  end

  def sanitize(str)
    str.gsub(/[^a-z0-9\-]+/i, ' ')
  end

system 'cls'
puts "\n\n\t X-raying Dashboards"
puts "\n\n\t # Dashboards  Workbook"
puts   "\n\t ------------  ----------------------"

path = if ARGV.empty? then '*.twb' else ARGV[0] end
Dir.glob(path) {|twb| xray twb }
