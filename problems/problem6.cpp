typedef struct No
 {
 	var value: int;
 	var left: No
    var right: No;
 };

 function newNo(var value: int, var no: No): No {
    if (no.value == null) {
        no.value = value;
        return no;
    }; else {
        if (value > no.value) {
                no.left = newNo (value, no.left);
        }; else {
            no.right = newNo (value, no.right)
        };
    }
    return newNode;
};

function printInOrder (var no: Node) {
    if (no != null) {
        printInOrder(node.left);
        printf (node.value + " - ");
        printInOrder (node.right);
    };
};

