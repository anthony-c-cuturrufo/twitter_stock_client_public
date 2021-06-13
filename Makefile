MODULES= json_writer config config_maker sentiment twitter stock parser main email trade curl algoUtils algo trader author manager
OBJECTS=$(MODULES:=.cmo)
MLS=$(MODULES:=.ml)
MLIS=$(MODULES:=.mli)
TEST=test.byte
MAIN=main.byte
CONFIG=config_maker.byte
OCAMLBUILD=ocamlbuild -use-ocamlfind
PKGS=unix,ounit2,lwt,cohttp,cohttp-lwt-unix,letters,conduit-lwt,csv,core

default: build
	OCAMLRUNPARAM=b utop

build:
	$(OCAMLBUILD) $(OBJECTS)

test:
	$(OCAMLBUILD) -tag 'debug' $(TEST) && ./$(TEST) -runner sequential

start:
	$(OCAMLBUILD) -tag 'debug' $(MAIN) && OCAMLRUNPARAM=b ./$(MAIN)

config:
	$(OCAMLBUILD) -tag 'debug' $(CONFIG) && OCAMLRUNPARAM=b ./$(CONFIG)

zip:
	zip twitter_stock_client.zip *.ml* *.json *.sh _tags .merlin .ocamlformat .ocamlinit LICENSE Makefile	
	
docs: docs-public docs-private
	
docs-public: build
	mkdir -p _doc.public
	ocamlfind ocamldoc -I _build -package yojson,ANSITerminal,cohttp,cohttp-lwt-unix,core,letters,csv \
		-html -stars -d _doc.public $(MLIS)

docs-private: build
	mkdir -p _doc.private
	ocamlfind ocamldoc -I _build -package yojson,ANSITerminal,cohttp,cohttp-lwt-unix,core,letters,csv \
		-html -stars -d _doc.private \
		-inv-merge-ml-mli -m A $(MLIS) $(MLS)

clean:
	ocamlbuild -clean
	rm -rf _doc.public _doc.private twitter_stock_client.zip