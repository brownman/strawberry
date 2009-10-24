# Strawberry!

    888888888888888888888888888888888888888888888888
    888888888888888888888888888888888888888888888888
    888888888888888888888888888C:O888888888888888888
    8888888888888888888888888Ooc88888888888888888888
    888888888888888888888888Cco888888888888888888888
    88888888888888888888888Occ8888888888888888888888
    88888888888888888OOOOOOC:C8OOOO88888888888888888
    8888888888888OCCCCCoocoCoCc.:::oCCoCO88888888888
    88888888888OooCc...:coc:oC:ccc:::::oCO8888888888
    8888888888occcc:::cooooccccccccc::::cO8888888888
    88888888Occcccc:ccCCoCCooooooocccc::::o888888888
    8888888OcccccccoCCC88Cocccoooocccc:::::c88888888
    8888888o:ccccccoCCCOCCcccccccooocc::::::o8888888
    8888888c::::cc:coccocccc:cccccccc::::::.c8888888
    8888888O::::::cc::::c:cc::::::::::::::..o8888888
    88888888o....::::c:::::::::::::::......c88888888
    888888888c.........:.:..::::...:......:O88888888
    8888888888o..........................:O888888888
    88888888888O.... ...................o88888888888
    8888888888888C     . .... ........c8888888888888
    888888888888888O.      .........o888888888888888
    888888888888888888c      .....o88888888888888888
    88888888888888888888o   ....C8888888888888888888
    8888888888888888888888OocoO888888888888888888888

## Well. So what's goin' on?

Strawberry is an experimental data storage solution
developed by Dmitry A. Ustalov (aka eveel) of Peppery.

Main idea of Strawberry lies on manipulation of
following things and concepts:

* like CDBMS: plain tables.
* like RDBMS: those tables metadata.
* yeah: every table is a node of table tree.

I'm too lazy to completely explain all Strawberry'
functionality here, but sure 'dat you able to:

* roll the tables of tree.
* roll their metadata to completely descibe your
entities attributes.

I sure, you can (but Strawberry is useless here):

* drink beer.
* grow a moustache.
* have hookers for lunch every day.
* and much, much more!

If you wanna run all this great things:

 * ruby (mri) 1.8.x or 1.9.1 or latest ruby (ree).
 * installed tokyocabinet library.
 * installed rufus-tokyo gem.

## Looks funny, but why I may be interested?

Alright, just watch and see:

    #!/usr/bin/env ruby

    FileUtils.rm_rf 'db' if File.directory? 'db'
    FileUtils.mkdir_p 'db'

    require 'strawberry'

    root = Strawberry::Base.at 'db'
    employees = root >> 'employees'

    vasya = employees >> 'Vasya'
    # here you can put any Vasya-related array(!) data
    vasya.meta = { 'salary' => '1500', 'iq' => '120' }
    vasya.data = [ 1000, 1100, 910, 210 ]

    # also you can access necessary table directly
    # and it'll be created automatically
    masha = root >> 'employees' >> 'Masha'
    masha.meta = { 'salary' => '1500', 'iq' => '120' }
    masha.data = [ 1000, 1100, 910, 210 ]

    # and write down acquired data
    employees.childs.each do |c|
      puts "#{c.name}: #{c.meta.inspect}"
      puts "#{c.data.inspect}"
      puts
    end

## Why you're still here?

Perhaps, you'd better should watch examples, sources
or tests.

Ah, yeah. If you wanna test Strawberry, install the
wonderful shoulda testing library, which used by.

## To-Do List

Like any growing project, Strawberry has some cons,
which'll be fixed soon:

 * stupid table name resolution in DAO.
 * empty RDoc.
 * perhaps, incomplete test coverage.

### Credits

Original idea and development
by Dmitry A. Ustalov (aka [eveel](http://www.eveel.ru/))
of [Peppery](http://www.peppery.me/).
