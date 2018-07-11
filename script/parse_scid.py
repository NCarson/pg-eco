
import sys
import chess

board = chess.Board()

last_opening = None
last_var = None
last_subvar = None

def parse(f):
    sys.stderr.write("parsing scid.eco ...")
    eco, name, moves = None, None, None
    n = -1
    flag = False

    for line in f:
        n += 1
        if line[0] in '\n#':
            continue

        pieces = line.split('"')
        if len(pieces) > 1:
            if eco:
                flush(n, eco, name, moves)
                moves = ''

            eco = pieces[0].strip()
            name = pieces[1]
            try:
                moves = pieces[2].strip()
            except IndexError:
                raise Exception(n, line.strip())
        else:
            if moves:
                moves += ' '
            moves += pieces[0].strip()
            flag = True
    flush(n, eco, name, moves)

def flush(ln, eco, name, moves):
    if not moves:
        raise Exception(eco, name)
    moves = ' '.join(moves.split()[:-1])
    halfmoves = len(moves.split())
    #print("|{}|{}|{}|".format(eco, name, moves))
    board.reset()
    for move in moves.split():
        if move == '*':
            continue
        if move.find('.') > -1:
            move = move.split('.')[1]

        if not move:
            continue
        try:
            move = board.parse_san(move)
        except ValueError:
            raise ValueError(repr(move), eco, name, moves, ln)
        board.push(move)
    #print(board.fen())

    vars =  ['\\N']*5
    if name.find(':') > -1:
        try:
            name, var = name.split(': ')
        except ValueError:
            pieces = name.split(': ')
            name, var = pieces[0], ', '.join(pieces[1:])

        if var.find(',') > -1:
            for i, piece in enumerate(var.split(', ')):
                try:
                    vars[i] = piece
                except IndexError:
                    raise ValueError(var, ln)
        else:
            vars[0] = var

    global last_opening
    global last_var
    global last_subvar

    for v, lv in (vars[0:2], (last_var, last_subvar)):
        if last_opening == name and not lv[0].isnumeric() \
                and not v.endswith("Accepted") \
                and not v.endswith("Declined") \
                and not (lv.endswith("Accepted") and v.endswith("Gambit")):

            try:
                if lv.split()[0] == v.split()[0]:
                    if lv != v:
                        sys.stderr.write("warning: {}, {} vs. {}, {}\n".format(
                            last_opening, lv, name, v))
            except IndexError:
                raise ValueError(lv, v, ln)

    last_opening = name
    last_var = vars[0]
    last_subvar = vars[1]

    sys.stdout.write(("{}\t"*9+"{}\n").format(
        eco, name, vars[0], vars[1], vars[2], vars[3], vars[4], board.fen(),
        moves, halfmoves))

if __name__ == '__main__':
    parse(open('data/scid.eco'))
