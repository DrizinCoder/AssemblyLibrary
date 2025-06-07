#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#pragma pack(push, 1)
typedef struct {
    unsigned short type;
    unsigned int size;
    unsigned short reserved1;
    unsigned short reserved2;
    unsigned int offset;
} BMPHeader;

typedef struct {
    unsigned int size;
    int width;
    int height;
    unsigned short planes;
    unsigned short bitsPerPixel;
    unsigned int compression;
    unsigned int imageSize;
    int xPixelsPerMeter;
    int yPixelsPerMeter;
    unsigned int colorsUsed;
    unsigned int importantColors;
} DIBHeader;

typedef struct {
    unsigned char blue;
    unsigned char green;
    unsigned char red;
} RGB;
#pragma pack(pop)

int convert_to_grayscale(const char* imageName) {
    char inputPath[256];
    char outputPath[256];

    // monta o caminho de entrada
    snprintf(inputPath, sizeof(inputPath), "../images/data/%s.bmp", imageName);

    FILE* input = fopen(inputPath, "rb");
    if (!input) {
        perror("\nErro ao abrir imagem de entrada");
        return 1;
    }

    FILE* output = fopen("../images/grayscale/current_grayscale.bmp", "wb");
    if (!output) {
        perror("\nErro ao criar imagem de saida");
        fclose(input);
        return 1;
    }

    BMPHeader bmpHeader;
    DIBHeader dibHeader;

    fread(&bmpHeader, sizeof(BMPHeader), 1, input);
    fread(&dibHeader, sizeof(DIBHeader), 1, input);

    if (bmpHeader.type != 0x4D42 || dibHeader.bitsPerPixel != 24) {
        printf("Apenas imagens BMP 24bpp são suportadas.\n");
        fclose(input);
        fclose(output);
        return 1;
    }

    fwrite(&bmpHeader, sizeof(BMPHeader), 1, output);
    fwrite(&dibHeader, sizeof(DIBHeader), 1, output);

    int padding = (4 - (dibHeader.width * 3) % 4) % 4;

    for (int i = 0; i < dibHeader.height; i++) {
        for (int j = 0; j < dibHeader.width; j++) {
            RGB pixel;
            fread(&pixel, sizeof(RGB), 1, input);

            unsigned char gray = (pixel.red + pixel.green + pixel.blue) / 3;
            pixel.red = pixel.green = pixel.blue = gray;

            fwrite(&pixel, sizeof(RGB), 1, output);
        }
        fseek(input, padding, SEEK_CUR);
        for (int k = 0; k < padding; k++) {
            fputc(0x00, output);
        }
    }

    fclose(input);
    fclose(output);

    printf("\nImagem '%s' convertida com sucesso para escala de cinza e salva em '%s'\n", imageName, outputPath);
    return 0;
}

int main() {
    int condition = 0;

    do {
        char imageName[100];

        printf("Digite o nome da imagem: ");
        scanf("%99s", imageName);

        convert_to_grayscale(imageName);


        printf("\n1 - Continuar\n0 - Sair\n\nDigite: ");
        scanf("%d", &condition);

        if (condition == 1) printf("\n");
        else printf("\nSaindo...");
    } while (condition);

    return 0;
}
