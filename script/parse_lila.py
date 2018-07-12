
import sys

def parse(f):
    d = {}
    count = 0
    null = '\\N'
    ln = 0
    #Grob Opening: Grob Gambit, Basman Gambit
    incomment = False
    for line in f:
        ln += 1
        line = line.strip()
        if line.find('*/') > -1:
            incomment = False
        if line.find('/*') > -1:
            incomment = True
        if incomment:
            continue
        if not line.startswith('new FullOpening('):
            continue

        pieces = line.split('"')
        eco = pieces[1]
        name = pieces[3]
        fen = pieces[5]
        pieces = name.split(': ')
        if len(pieces) > 2:
            raise ValueError(pieces, ln)
        name = pieces[0]


        if len(pieces) > 1:
            var = pieces[1]
            if var.find(', ') > -1:
                try:
                    var, subvar = var.split(', ')
                    subsubvar = null
                except ValueError:
                    try:
                        var, subvar, subsubvar = var.split(', ')
                    except ValueError:
                        raise Exception("bad var %s" % repr(var))
            else:
                subvar, subsubvar = null, null
        elif  name.find(',') > -1:
            raise ValueError(name)
        else:
            var, subvar, subsubvar = null, null, null


        count += 1
        #fix meta
        remove = ['#', 'Formation', 'Accelerated', 'Defense', 'Attack',
                'Opening', 'Game', 'Complex', "Accepted", "Declined",
                "Gambit", "Countergambit", "System"]

        exceptions = ["Bishop's Opening", "King's Pawn Game", "Queen's Pawn Game"
                , "Queen's Gambit Accepted", "Queen's Gambit Declined", "King's Gambit Accepted",
                "King's Gambit Declined", "Queen's Gambit Refused"]

        meta = name.split(',')[0]
        for r in remove:
            if meta in exceptions:
                continue
            if meta.find(' ' + r) > 0:
                meta = meta[:meta.find(' ' + r)]

        if meta == 'Nimzowitsch-Larsen':
            meta = 'Nimzo-Larsen'
        if meta == "King's": # counter gambits
            meta = "King's Gambit Declined"
        if meta == "Queen's": # move 2 position, so prob a strange var
            meta = "Queen's Gambit Declined"
        if meta == "Queen's Pawn":
            meta = "Queen's Pawn Game"
        if meta == "King's Pawn":
            meta = "King's Pawn Game"

        #fix name
        if name.find(' #') > 0:
            if var != null:
                raise ValueError(var)
            name, var = name.split(' #')


        #fix var
        #remove = ['Variation']
        remove = []
        for r in remove:
            if var.find(' ' + r) > 0:
                var = var[:var.find(' ' + r)]

        d[meta] = None
        sys.stdout.write("{}\t{}\t{}\t{}\t{}\t{}\t{} -\n".format(
            eco, meta, name,
            var, subvar, subsubvar, fen))

    #for name in sorted(d.keys()):
    #    print('|' + name + '|')

if __name__ == '__main__':
    parse(open('data/lila/FullOpeningPart1.scala'))
    parse(open('data/lila/FullOpeningPart2.scala'))
