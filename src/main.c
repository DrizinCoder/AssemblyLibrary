#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

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

void driver(int8_t* kernel, uint8_t* region, uint8_t* result, int size, int opcode) {
    int32_t sum = 0;

    int idx = 0;
    int count = 0;

    // Determinar o tamanho do kernel
    if (size == 0) count = 2;  // 2x2
    else if (size == 1) count = 3; // 3x3
    else if (size == 2) count = 4; // 4x4
    else if (size == 3) count = 5; // 5x5
    // Adicione outros tamanhos se necessário

    if (opcode == 1) {
        for (int ky = 0; ky < count; ky++) {
            for (int kx = 0; kx < count; kx++) {
                sum += kernel[ky * count + kx] * region[ky * count + kx];
            }
        }

        // Retorna o resultado em 4 posições (uint8_t)
        result[0] = (sum >> 24) & 0xFF;      // Byte mais significativo
        result[1] = (sum >> 16) & 0xFF;
        result[2] = (sum >> 8) & 0xFF;
        result[3] = sum & 0xFF;              // Byte menos significativo
    }

    // Laplaciano
    else if (opcode == 2) {
        for (int ky = 0; ky < count; ky++) {
            for (int kx = 0; kx < count; kx++) {
                sum += kernel[ky * count + kx] * region[ky * count + kx];
            }
        }

        // Clipping
        if (sum > 255) sum = 255;
        else if (sum < 0) sum = 0;

        // Retornar o resultado na primeira posição
        result[0] = (uint8_t)sum;
    }
}

void apply_laplaciano() {
    FILE* input = fopen("../images/grayscale/current_grayscale.bmp", "rb");
    if (!input) {
        perror("Erro ao abrir a imagem em escala de cinza");
        return;
    }

    FILE* output = fopen("../images/output/laplaciano.bmp", "wb");
    if (!output) {
        perror("Erro ao criar a imagem de saída do filtro Laplaciano");
        fclose(input);
        return;
    }

    BMPHeader bmpHeader;
    DIBHeader dibHeader;
    fread(&bmpHeader, sizeof(BMPHeader), 1, input);
    fread(&dibHeader, sizeof(DIBHeader), 1, input);
    fwrite(&bmpHeader, sizeof(BMPHeader), 1, output);
    fwrite(&dibHeader, sizeof(DIBHeader), 1, output);

    int width = dibHeader.width;
    int height = dibHeader.height;
    int padding = (4 - (width * 3) % 4) % 4;
    int size = width * height;

    unsigned char* gray = malloc(size);
    unsigned char* result = calloc(size, 1);

    // Ler imagem em escala de cinza
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            RGB pixel;
            fread(&pixel, sizeof(RGB), 1, input);
            gray[i * width + j] = pixel.red;
        }
        fseek(input, padding, SEEK_CUR);
    }

    fclose(input);
    int8_t laplacian_mask[25] = {
        0,  0, -1,  0,  0,
        0, -1, -2, -1,  0,
       -1, -2, 16, -2, -1,
        0, -1, -2, -1,  0,
        0,  0, -1,  0,  0
    };


    uint8_t region[25];
    uint8_t driver_result[25];

    // Aplicar convolução com driver
    for (int y = 2; y < height - 2; y++) {
        for (int x = 2; x < width - 2; x++) {
            // Extrair a região 5x5 ao redor do pixel (x,y)
            int idx = 0;
            for (int ky = -2; ky <= 2; ky++) {
                for (int kx = -2; kx <= 2; kx++) {
                    region[idx++] = gray[(y + ky) * width + (x + kx)];
                }
            }

            driver(laplacian_mask, region, driver_result, 3, 2); // size=1 para 5x5, opcode=2 para Laplaciano

            result[y * width + x] = driver_result[0];
        }
    }

    // Escrever resultado
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            unsigned char val = result[i * width + j];
            RGB pixel = { val, val, val };
            fwrite(&pixel, sizeof(RGB), 1, output);
        }
        for (int k = 0; k < padding; k++) {
            fputc(0x00, output);
        }
    }

    fclose(output);
    free(gray);
    free(result);

    printf("\nFiltro Laplaciano 5x5 aplicado com sucesso. Imagem salva em '../images/output/laplaciano.bmp'\n");
}

void apply_prewitt() {
    FILE* input = fopen("../images/grayscale/current_grayscale.bmp", "rb");
    if (!input) {
        perror("Erro ao abrir a imagem em escala de cinza");
        return;
    }

    FILE* output = fopen("../images/output/prewitt.bmp", "wb");
    if (!output) {
        perror("Erro ao criar a imagem de saída do filtro Prewitt");
        fclose(input);
        return;
    }

    BMPHeader bmpHeader;
    DIBHeader dibHeader;
    fread(&bmpHeader, sizeof(BMPHeader), 1, input);
    fread(&dibHeader, sizeof(DIBHeader), 1, input);
    fwrite(&bmpHeader, sizeof(BMPHeader), 1, output);
    fwrite(&dibHeader, sizeof(DIBHeader), 1, output);

    int width = dibHeader.width;
    int height = dibHeader.height;
    int padding = (4 - (width * 3) % 4) % 4;
    int size = width * height;

    unsigned char* gray = malloc(size);
    unsigned char* result_x = calloc(size, 1);
    unsigned char* result_y = calloc(size, 1);
    unsigned char* result = calloc(size, 1);

    // Ler imagem
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            RGB pixel;
            fread(&pixel, sizeof(RGB), 1, input);
            gray[i * width + j] = pixel.red;
        }
        fseek(input, padding, SEEK_CUR);
    }
    fclose(input);

    // Máscaras de Prewitt
    int8_t prewitt_x[9] = { -1, 0, 1, -1, 0, 1, -1, 0, 1 };
    int8_t prewitt_y[9] = { -1, -1, -1, 0, 0, 0, 1, 1, 1 };

    // Aplicar convolução
    for (int i = 1; i < height - 1; i++) {
        for (int j = 1; j < width - 1; j++) {
            int8_t region[9];
            int idx = 0;
            for (int mi = 0; mi < 3; mi++) {
                for (int mj = 0; mj < 3; mj++) {
                    region[idx++] = gray[(i + mi - 1) * width + (j + mj - 1)];
                }
            }

            int8_t res_x[9], res_y[9];
            driver(prewitt_x, region, res_x, 1, 1);
            driver(prewitt_y, region, res_y, 1, 1);

            // Reconstruir os valores de 32 bits a partir dos bytes
            int32_t sum_x = (res_x[0] << 24) | (res_x[1] << 16) | (res_x[2] << 8) | res_x[3];
            int32_t sum_y = (res_y[0] << 24) | (res_y[1] << 16) | (res_y[2] << 8) | res_y[3];

            // Calcular magnitude do gradiente
            int32_t magnitude = abs(sum_x) + abs(sum_y);

            // Clipping
            if (magnitude > 255) magnitude = 255;
            else if (magnitude < 0) magnitude = 0;

            result[i * width + j] = (uint8_t)magnitude;
        }
    }

    // Escrever resultado
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            unsigned char val = result[i * width + j];
            RGB pixel = { val, val, val };
            fwrite(&pixel, sizeof(RGB), 1, output);
        }
        for (int k = 0; k < padding; k++) fputc(0x00, output);
    }

    fclose(output);
    free(gray);
    free(result_x);
    free(result_y);
    free(result);
    printf("\nFiltro Prewitt aplicado com sucesso. Imagem salva em '../images/output/prewitt.bmp'\n");
}

void apply_roberts() {
    FILE* input = fopen("../images/grayscale/current_grayscale.bmp", "rb");
    if (!input) {
        perror("Erro ao abrir a imagem em escala de cinza");
        return;
    }

    FILE* output = fopen("../images/output/roberts.bmp", "wb");
    if (!output) {
        perror("Erro ao criar a imagem de saída do filtro Roberts");
        fclose(input);
        return;
    }

    BMPHeader bmpHeader;
    DIBHeader dibHeader;
    fread(&bmpHeader, sizeof(BMPHeader), 1, input);
    fread(&dibHeader, sizeof(DIBHeader), 1, input);
    fwrite(&bmpHeader, sizeof(BMPHeader), 1, output);
    fwrite(&dibHeader, sizeof(DIBHeader), 1, output);

    int width = dibHeader.width;
    int height = dibHeader.height;
    int padding = (4 - (width * 3) % 4) % 4;
    int size = width * height;

    unsigned char* gray = malloc(size);
    unsigned char* result = calloc(size, 1);

    // Ler imagem
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            RGB pixel;
            fread(&pixel, sizeof(RGB), 1, input);
            gray[i * width + j] = pixel.red;
        }
        fseek(input, padding, SEEK_CUR);
    }
    fclose(input);

    // Máscaras de Roberts
    int8_t roberts_x[4] = { 1, 0, 0, -1 };
    int8_t roberts_y[4] = { 0, 1, -1, 0 };

    // Aplicar convolução
    for (int i = 1; i < height - 1; i++) {
        for (int j = 1; j < width - 1; j++) {
            int8_t region[9];
            int idx = 0;
            for (int mi = 0; mi < 3; mi++) {
                for (int mj = 0; mj < 3; mj++) {
                    region[idx++] = gray[(i + mi - 1) * width + (j + mj - 1)];
                }
            }

            int8_t res_x[4], res_y[4];
            driver(roberts_x, region, res_x, 0, 1);
            driver(roberts_y, region, res_y, 0, 1);

            // Reconstruir os valores de 32 bits a partir dos bytes
            int32_t sum_x = (res_x[0] << 24) | (res_x[1] << 16) | (res_x[2] << 8) | res_x[3];
            int32_t sum_y = (res_y[0] << 24) | (res_y[1] << 16) | (res_y[2] << 8) | res_y[3];

            // Calcular magnitude do gradiente
            int32_t magnitude = abs(sum_x) + abs(sum_y);

            // Clipping
            if (magnitude > 255) magnitude = 255;
            else if (magnitude < 0) magnitude = 0;

            result[i * width + j] = (uint8_t)magnitude;
        }
    }


    // Escrever resultado
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            unsigned char val = result[i * width + j];
            RGB pixel = { val, val, val };
            fwrite(&pixel, sizeof(RGB), 1, output);
        }
        for (int k = 0; k < padding; k++) fputc(0x00, output);
    }

    fclose(output);
    free(gray);
    free(result);
    printf("\nFiltro Roberts aplicado com sucesso. Imagem salva em '../images/output/roberts.bmp'\n");
}

void apply_sobel3x3() {
    FILE* input = fopen("../images/grayscale/current_grayscale.bmp", "rb");
    if (!input) {
        perror("Erro ao abrir a imagem em escala de cinza");
        return;
    }

    FILE* output = fopen("../images/output/sobel3x3.bmp", "wb");
    if (!output) {
        perror("Erro ao criar a imagem de saída do filtro Sobel 3x3");
        fclose(input);
        return;
    }

    BMPHeader bmpHeader;
    DIBHeader dibHeader;
    fread(&bmpHeader, sizeof(BMPHeader), 1, input);
    fread(&dibHeader, sizeof(DIBHeader), 1, input);
    fwrite(&bmpHeader, sizeof(BMPHeader), 1, output);
    fwrite(&dibHeader, sizeof(DIBHeader), 1, output);

    int width = dibHeader.width;
    int height = dibHeader.height;
    int padding = (4 - (width * 3) % 4) % 4;
    int size = width * height;

    unsigned char* gray = malloc(size);
    unsigned char* result_x = calloc(size, 1);
    unsigned char* result_y = calloc(size, 1);
    unsigned char* result = calloc(size, 1);

    // Ler imagem
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            RGB pixel;
            fread(&pixel, sizeof(RGB), 1, input);
            gray[i * width + j] = pixel.red;
        }
        fseek(input, padding, SEEK_CUR);
    }
    fclose(input);

    // Máscaras de Sobel 3x3
    int8_t sobel_x[9] = { -1, 0, 1, -2, 0, 2, -1, 0, 1 };
    int8_t sobel_y[9] = { -1, -2, -1, 0, 0, 0, 1, 2, 1 };

    // Aplicar convolução
    for (int i = 1; i < height - 1; i++) {
        for (int j = 1; j < width - 1; j++) {
            int8_t region[9];
            int idx = 0;
            for (int mi = 0; mi < 3; mi++) {
                for (int mj = 0; mj < 3; mj++) {
                    region[idx++] = gray[(i + mi - 1) * width + (j + mj - 1)];
                }
            }

            int8_t res_x[9], res_y[9];

            driver(sobel_x, region, res_x, 1, 1);
            driver(sobel_y, region, res_y, 1, 1);

            // Reconstruir os valores de 32 bits a partir dos bytes
            int32_t sum_x = (res_x[0] << 24) | (res_x[1] << 16) | (res_x[2] << 8) | res_x[3];
            int32_t sum_y = (res_y[0] << 24) | (res_y[1] << 16) | (res_y[2] << 8) | res_y[3];

            // Calcular magnitude do gradiente
            int32_t magnitude = abs(sum_x) + abs(sum_y);

            // Clipping
            if (magnitude > 255) magnitude = 255;
            else if (magnitude < 0) magnitude = 0;

            result[i * width + j] = (uint8_t)magnitude;
        }
    }

    // Escrever resultado
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            unsigned char val = result[i * width + j];
            RGB pixel = { val, val, val };
            fwrite(&pixel, sizeof(RGB), 1, output);
        }
        for (int k = 0; k < padding; k++) fputc(0x00, output);
    }

    fclose(output);
    free(gray);
    free(result_x);
    free(result_y);
    free(result);
    printf("\nFiltro Sobel 3x3 aplicado com sucesso. Imagem salva em '../images/output/sobel3x3.bmp'\n");
}

void apply_sobel5x5() {
    FILE* input = fopen("../images/grayscale/current_grayscale.bmp", "rb");
    if (!input) {
        perror("Erro ao abrir a imagem em escala de cinza");
        return;
    }

    FILE* output = fopen("../images/output/sobel5x5.bmp", "wb");
    if (!output) {
        perror("Erro ao criar a imagem de saída do filtro Sobel 5x5");
        fclose(input);
        return;
    }

    BMPHeader bmpHeader;
    DIBHeader dibHeader;
    fread(&bmpHeader, sizeof(BMPHeader), 1, input);
    fread(&dibHeader, sizeof(DIBHeader), 1, input);
    fwrite(&bmpHeader, sizeof(BMPHeader), 1, output);
    fwrite(&dibHeader, sizeof(DIBHeader), 1, output);

    int width = dibHeader.width;
    int height = dibHeader.height;
    int padding = (4 - (width * 3) % 4) % 4;
    int size = width * height;

    unsigned char* gray = malloc(size);
    unsigned char* result_x = calloc(size, 1);
    unsigned char* result_y = calloc(size, 1);
    unsigned char* result = calloc(size, 1);

    // Ler imagem
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            RGB pixel;
            fread(&pixel, sizeof(RGB), 1, input);
            gray[i * width + j] = pixel.red;
        }
        fseek(input, padding, SEEK_CUR);
    }
    fclose(input);

    // Máscaras de Sobel 5x5
    int8_t sobel_x[25] = {
        -1, -2, 0, 2, 1,
        -2, -3, 0, 3, 2,
        -3, -4, 0, 4, 3,
        -2, -3, 0, 3, 2,
        -1, -2, 0, 2, 1
    };

    int8_t sobel_y[25] = {
        -1, -2, -3, -2, -1,
        -2, -3, -4, -3, -2,
         0,  0,  0,  0,  0,
         2,  3,  4,  3,  2,
         1,  2,  3,  2,  1
    };

    // // Máscaras de Sobel 5x5
    // int8_t sobel_x[25] = {
    //     2, 2, 4, 2, 2,
    //     1, 1, 2, 1, 1,
    //     0, 0, 0, 0, 0,
    //     -1, -1, -2, -1, -1,
    //     -2, -2, -4, -2, -2
    // };

    // int8_t sobel_y[25] = {
    //     -2, -1,  0,  1,  2,
    //     -2, -1,  0,  1,  2,
    //     -4, -2,  0,  2,  4,
    //     -2, -1,  0,  1,  2,
    //     -2, -1,  0,  1,  2
    // };


    // Aplicar convolução
    for (int i = 2; i < height - 2; i++) {
        for (int j = 2; j < width - 2; j++) {
            int8_t region[25];
            int idx = 0;

            for (int mi = 0; mi < 5; mi++) {
                for (int mj = 0; mj < 5; mj++) {
                    region[idx++] = gray[(i + mi - 2) * width + (j + mj - 2)];
                }
            }

            int8_t res_x[25], res_y[25];

            driver(sobel_x, region, res_x, 3, 1);
            driver(sobel_y, region, res_y, 3, 1);

            // Reconstruir os valores de 32 bits a partir dos bytes
            int32_t sum_x = (res_x[0] << 24) | (res_x[1] << 16) | (res_x[2] << 8) | res_x[3];
            int32_t sum_y = (res_y[0] << 24) | (res_y[1] << 16) | (res_y[2] << 8) | res_y[3];

            // Calcular magnitude do gradiente
            int32_t magnitude = abs(sum_x) + abs(sum_y);

            magnitude = magnitude / 16; // Ajuste empírico para manter valores em 0-255

            // Clipping
            if (magnitude > 255) magnitude = 255;
            else if (magnitude < 0) magnitude = 0;

            result[i * width + j] = magnitude;
        }
    }

    // Escrever resultado
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            unsigned char val = result[i * width + j];
            RGB pixel = { val, val, val };
            fwrite(&pixel, sizeof(RGB), 1, output);
        }
        for (int k = 0; k < padding; k++) fputc(0x00, output);
    }

    fclose(output);
    free(gray);
    free(result_x);
    free(result_y);
    free(result);
    printf("\nFiltro Sobel 5x5 aplicado com sucesso. Imagem salva em '../images/output/sobel5x5.bmp'\n");
}

// extern void mmap_setup();
// extern void driver(int8_t *matrixA, int8_t *matrixB, uint8_t *matrixR, int size, int op_opcode);
// extern void mmap_cleanup();

int main() {
    //  mmap_setup();

    int condition = 0;

    do {
        char imageName[100];
        printf("Digite o nome da imagem: ");
        scanf("%99s", imageName);
        convert_to_grayscale(imageName);

        int menu = 0;

        do
        {
            printf("\nEdge Detection Filters\n");
            printf("1 - Laplaciano\n2 - Prewitt\n3 - Roberts\n4 - Sobel 3x3\n5 - Sobel 5x5\nSair - 0\n\nDigite: ");
            scanf("%d", &menu);

            if (menu == 1) {
                apply_laplaciano();
            }
            else if (menu == 2) {
                apply_prewitt();
            }
            else if (menu == 3) {
                apply_roberts();
            }
            else if (menu == 4) {
                apply_sobel3x3();
            }
            else if (menu == 5) {
                apply_sobel5x5();
            }
            else if (menu == 0) {
                printf("\nSaindo do menu...\n");
            }


        } while (menu);

        printf("\n1 - Continuar\n0 - Sair\n\nDigite: ");
        scanf("%d", &condition);

        if (condition == 1) printf("\n");
        else printf("\nSaindo do programa...");
    } while (condition);

    //mmap_cleanup();
    return 0;
}
